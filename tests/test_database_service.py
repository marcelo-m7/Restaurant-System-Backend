from fastapi.testclient import TestClient

from database_service.main import app


client = TestClient(app)


def headers(tenant: str) -> dict[str, str]:
    return {"X-Tenant-Id": tenant}


def test_tenant_isolation_for_products():
    tenant_a = "tenant-a"
    tenant_b = "tenant-b"

    category_a = client.post("/v1/categories", json={"name": "Food", "description": "A"}, headers=headers(tenant_a)).json()
    category_b = client.post("/v1/categories", json={"name": "Drinks", "description": "B"}, headers=headers(tenant_b)).json()

    product_a = client.post(
        "/v1/products",
        json={"name": "Burger", "price": 12.5, "category_id": category_a["id"]},
        headers=headers(tenant_a),
    )
    assert product_a.status_code == 200

    product_b = client.post(
        "/v1/products",
        json={"name": "Cola", "price": 5.0, "category_id": category_b["id"]},
        headers=headers(tenant_b),
    )
    assert product_b.status_code == 200

    response_a = client.get("/v1/products", headers=headers(tenant_a))
    response_b = client.get("/v1/products", headers=headers(tenant_b))

    assert [item["name"] for item in response_a.json()] == ["Burger"]
    assert [item["name"] for item in response_b.json()] == ["Cola"]


def test_cross_tenant_read_update_delete_are_blocked():
    tenant_a = "tenant-a-lock"
    tenant_b = "tenant-b-lock"

    category = client.post("/v1/categories", json={"name": "Food", "description": "A"}, headers=headers(tenant_a)).json()
    product = client.post(
        "/v1/products",
        json={"name": "Pasta", "price": 18.0, "category_id": category["id"]},
        headers=headers(tenant_a),
    ).json()

    read = client.get(f"/v1/products/{product['id']}", headers=headers(tenant_b))
    update = client.put(
        f"/v1/products/{product['id']}",
        json={"name": "Hack", "price": 1.0, "category_id": category["id"]},
        headers=headers(tenant_b),
    )
    delete = client.delete(f"/v1/products/{product['id']}", headers=headers(tenant_b))

    assert read.status_code == 403
    assert update.status_code == 403
    assert delete.status_code == 403


def test_crud_lifecycle_for_order_tables():
    tenant = "tenant-crud"
    hdrs = headers(tenant)

    category = client.post("/v1/categories", json={"name": "Main", "description": "X"}, headers=hdrs).json()
    product = client.post("/v1/products", json={"name": "Soup", "price": 7.5, "category_id": category["id"]}, headers=hdrs).json()
    table = client.post("/v1/tables", json={"name": "T1", "seats": 4, "status": "available"}, headers=hdrs).json()
    tab = client.post("/v1/tabs", json={"table_id": table["id"], "status": "open"}, headers=hdrs).json()
    order = client.post("/v1/orders", json={"tab_id": tab["id"], "status": "open", "notes": "none"}, headers=hdrs).json()

    order_item = client.post(
        "/v1/order-items",
        json={"order_id": order["id"], "product_id": product["id"], "quantity": 2, "unit_price": 7.5},
        headers=hdrs,
    )
    assert order_item.status_code == 200

    payment = client.post(
        "/v1/payments",
        json={"order_id": order["id"], "amount": 15.0, "method": "card", "status": "received"},
        headers=hdrs,
    )
    assert payment.status_code == 200

    update_order = client.put(
        f"/v1/orders/{order['id']}",
        json={"tab_id": tab["id"], "status": "closed", "notes": "paid"},
        headers=hdrs,
    )
    assert update_order.status_code == 200
    assert update_order.json()["status"] == "closed"

    delete_payment = client.delete(f"/v1/payments/{payment.json()['id']}", headers=hdrs)
    assert delete_payment.status_code == 204
