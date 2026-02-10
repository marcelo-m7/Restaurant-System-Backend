from fastapi.testclient import TestClient

from services.database_service.main import TenantHeader, create_app


def setup_domain(client: TestClient, headers: dict[str, str]) -> dict[str, int]:
    category = client.post("/categories", headers=headers, json={"name": "Main"}).json()
    product = client.post(
        "/products", headers=headers, json={"name": "Burger", "price": 10.0, "category_id": category["id"]}
    ).json()
    unit = client.post(
        "/units",
        headers=headers,
        json={"name": "Downtown", "timezone": "UTC", "service_fee_enabled": True, "service_fee_percent": 10},
    ).json()
    area = client.post("/areas", headers=headers, json={"unit_id": unit["id"], "name": "Hall", "sort_order": 1}).json()
    table = client.post(
        "/tables",
        headers=headers,
        json={"unit_id": unit["id"], "area_id": area["id"], "name": "T1", "capacity": 4, "status": "available"},
    ).json()
    return {"product_id": product["id"], "unit_id": unit["id"], "table_id": table["id"]}


def test_domain_flows_and_financial_recalculation() -> None:
    client = TestClient(create_app())
    headers = {TenantHeader: "tenant-a"}
    setup = setup_domain(client, headers)

    tab = client.post("/tabs/open", headers=headers, json={"unit_id": setup["unit_id"], "table_id": setup["table_id"]})
    assert tab.status_code == 201
    tab_id = tab.json()["id"]

    order = client.post("/orders", headers=headers, json={"tab_id": tab_id})
    assert order.status_code == 201
    order_id = order.json()["id"]

    send_without_items = client.post(f"/orders/{order_id}/send", headers=headers)
    assert send_without_items.status_code == 409

    item = client.post(
        "/order-items", headers=headers, json={"order_id": order_id, "product_id": setup["product_id"], "quantity": 2}
    )
    assert item.status_code == 201
    assert item.json()["product_name_snapshot"] == "Burger"
    assert item.json()["unit_price_snapshot"] == 10.0
    item_id = item.json()["id"]

    # Snapshot must remain stable even when product price changes.
    update_product = client.put(
        f"/products/{setup['product_id']}", headers=headers, json={"name": "Burger", "price": 20.0, "category_id": 1}
    )
    assert update_product.status_code == 200

    send_order = client.post(f"/orders/{order_id}/send", headers=headers)
    assert send_order.status_code == 200

    immutable_after_send = client.post(
        "/order-items", headers=headers, json={"order_id": order_id, "product_id": setup["product_id"], "quantity": 1}
    )
    assert immutable_after_send.status_code == 409

    tab_totals = client.post(f"/tabs/{tab_id}/recalculate", headers=headers)
    assert tab_totals.status_code == 200
    assert tab_totals.json()["subtotal_amount"] == 20.0
    assert tab_totals.json()["service_fee_amount"] == 2.0
    assert tab_totals.json()["total_amount"] == 22.0
    assert tab_totals.json()["due_amount"] == 22.0

    overpay = client.post("/payments", headers=headers, json={"tab_id": tab_id, "amount": 25.0, "method": "card"})
    assert overpay.status_code == 409

    payment = client.post("/payments", headers=headers, json={"tab_id": tab_id, "amount": 22.0, "method": "card"})
    assert payment.status_code == 201
    payment_id = payment.json()["id"]

    confirm = client.post(f"/payments/{payment_id}/confirm", headers=headers)
    assert confirm.status_code == 200
    assert confirm.json()["status"] == "paid"
    assert confirm.json()["paid_at"] is not None

    closed = client.post(f"/tabs/{tab_id}/close", headers=headers)
    assert closed.status_code == 200
    assert closed.json()["status"] == "closed"

    # Cannot open second tab while first one is open.
    setup2 = setup_domain(client, {TenantHeader: "tenant-b"})
    tenant_b = {TenantHeader: "tenant-b"}
    first = client.post(
        "/tabs/open", headers=tenant_b, json={"unit_id": setup2["unit_id"], "table_id": setup2["table_id"]}
    )
    assert first.status_code == 201
    second = client.post(
        "/tabs/open", headers=tenant_b, json={"unit_id": setup2["unit_id"], "table_id": setup2["table_id"]}
    )
    assert second.status_code == 409

    voided = client.post(f"/order-items/{item_id}/void", headers=headers)
    assert voided.status_code == 200


def test_tenant_isolation_on_domain_endpoints() -> None:
    client = TestClient(create_app())
    tenant_a = {TenantHeader: "tenant-a"}
    tenant_b = {TenantHeader: "tenant-b"}
    setup = setup_domain(client, tenant_a)

    tab = client.post(
        "/tabs/open", headers=tenant_a, json={"unit_id": setup["unit_id"], "table_id": setup["table_id"]}
    ).json()
    denied = client.post("/orders", headers=tenant_b, json={"tab_id": tab["id"]})
    assert denied.status_code == 404


def test_missing_tenant_header_is_rejected() -> None:
    client = TestClient(create_app())
    response = client.get("/categories")
    assert response.status_code == 400
    assert response.json()["error"] == "missing_tenant"


def test_domain_order_creation_uses_domain_route_not_generic_crud() -> None:
    client = TestClient(create_app())
    headers = {TenantHeader: "tenant-a"}
    setup = setup_domain(client, headers)
    tab_id = client.post(
        "/tabs/open", headers=headers, json={"unit_id": setup["unit_id"], "table_id": setup["table_id"]}
    ).json()["id"]

    response = client.post("/orders", headers=headers, json={"tab_id": tab_id})

    assert response.status_code == 201
    assert response.json()["status"] == "draft"


def test_http_errors_return_consistent_error_schema() -> None:
    client = TestClient(create_app())

    response = client.get("/categories")

    assert response.status_code == 400
    assert response.json() == {"error": "missing_tenant", "detail": f"{TenantHeader} header required"}
