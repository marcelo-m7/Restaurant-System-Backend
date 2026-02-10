from fastapi.testclient import TestClient

from services.database_service.main import create_app, TenantHeader


def test_tenant_isolation_and_crud_lifecycle() -> None:
    client = TestClient(create_app())

    tenant_a = {TenantHeader: "tenant-a"}
    tenant_b = {TenantHeader: "tenant-b"}

    category_payload = {"name": "Burgers"}
    created_category = client.post("/categories", headers=tenant_a, json=category_payload)
    assert created_category.status_code == 201
    category_id = created_category.json()["id"]

    product_payload = {"name": "Classic Burger", "price": 18.5, "category_id": category_id}
    created_product = client.post("/products", headers=tenant_a, json=product_payload)
    assert created_product.status_code == 201
    product_id = created_product.json()["id"]

    created_table = client.post("/tables", headers=tenant_a, json={"name": "T1", "seats": 4, "status": "available"})
    assert created_table.status_code == 201
    table_id = created_table.json()["id"]

    created_tab = client.post("/tabs", headers=tenant_a, json={"table_id": table_id, "status": "open"})
    assert created_tab.status_code == 201
    tab_id = created_tab.json()["id"]

    created_order = client.post("/orders", headers=tenant_a, json={"tab_id": tab_id, "status": "pending"})
    assert created_order.status_code == 201
    order_id = created_order.json()["id"]

    created_order_item = client.post(
        "/order-items",
        headers=tenant_a,
        json={"order_id": order_id, "product_id": product_id, "quantity": 2, "unit_price": 18.5},
    )
    assert created_order_item.status_code == 201

    created_payment = client.post(
        "/payments",
        headers=tenant_a,
        json={"tab_id": tab_id, "amount": 37.0, "method": "card", "status": "paid"},
    )
    assert created_payment.status_code == 201
    payment_id = created_payment.json()["id"]

    list_a = client.get("/products", headers=tenant_a)
    list_b = client.get("/products", headers=tenant_b)
    assert list_a.status_code == 200 and len(list_a.json()["items"]) == 1
    assert list_b.status_code == 200 and len(list_b.json()["items"]) == 0

    cross_read = client.get(f"/products/{product_id}", headers=tenant_b)
    cross_update = client.put(
        f"/products/{product_id}",
        headers=tenant_b,
        json={"name": "Hack", "price": 1.0, "category_id": category_id},
    )
    cross_delete = client.delete(f"/payments/{payment_id}", headers=tenant_b)
    assert cross_read.status_code == 404
    assert cross_update.status_code == 404
    assert cross_delete.status_code == 404

    updated = client.put(
        f"/products/{product_id}",
        headers=tenant_a,
        json={"name": "Classic Burger XL", "price": 20.0, "category_id": category_id},
    )
    assert updated.status_code == 200
    assert updated.json()["name"] == "Classic Burger XL"

    deleted = client.delete(f"/payments/{payment_id}", headers=tenant_a)
    assert deleted.status_code == 204


def test_missing_tenant_header_is_rejected() -> None:
    client = TestClient(create_app())
    response = client.get("/categories")
    assert response.status_code == 400
    assert response.json()["error"] == "missing_tenant"
