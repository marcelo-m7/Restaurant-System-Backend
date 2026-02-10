from __future__ import annotations

from fastapi.testclient import TestClient

from services.database_service.app import create_db_app


def test_tenant_isolation_and_cross_tenant_denied() -> None:
    client = TestClient(create_db_app())

    created = client.post(
        "/v1/products",
        headers={"X-Tenant-ID": "tenant-a"},
        json={"data": {"name": "Burger", "price": 10.0}},
    )
    assert created.status_code == 200
    product_id = created.json()["data"]["id"]

    tenant_a_items = client.get("/v1/products", headers={"X-Tenant-ID": "tenant-a"})
    tenant_b_items = client.get("/v1/products", headers={"X-Tenant-ID": "tenant-b"})
    assert len(tenant_a_items.json()["items"]) == 1
    assert tenant_b_items.json()["items"] == []

    forbidden = client.get(f"/v1/products/{product_id}", headers={"X-Tenant-ID": "tenant-b"})
    assert forbidden.status_code == 404
    assert forbidden.json()["detail"]["error"] == "TENANT_SCOPE_VIOLATION"


def test_crud_lifecycle_for_key_entities() -> None:
    client = TestClient(create_db_app())
    headers = {"X-Tenant-ID": "tenant-crud"}

    category = client.post("/v1/categories", headers=headers, json={"data": {"name": "Drinks"}}).json()["data"]
    table = client.post("/v1/tables", headers=headers, json={"data": {"name": "T1", "seats": 4}}).json()["data"]

    product = client.post(
        "/v1/products",
        headers=headers,
        json={"data": {"name": "Cola", "price": 4.5, "category_id": category["id"]}},
    ).json()["data"]

    tab = client.post("/v1/tabs", headers=headers, json={"data": {"table_id": table["id"], "status": "open"}}).json()["data"]
    order = client.post("/v1/orders", headers=headers, json={"data": {"tab_id": tab["id"], "status": "pending"}}).json()["data"]
    order_item = client.post(
        "/v1/order-items",
        headers=headers,
        json={"data": {"order_id": order["id"], "product_id": product["id"], "quantity": 2}},
    ).json()["data"]
    payment = client.post(
        "/v1/payments",
        headers=headers,
        json={"data": {"order_id": order["id"], "amount": 9.0, "method": "card"}},
    ).json()["data"]

    updated = client.put(f"/v1/products/{product['id']}", headers=headers, json={"data": {"price": 5.0}})
    assert updated.status_code == 200
    assert updated.json()["data"]["price"] == 5.0

    deleted = client.delete(f"/v1/order-items/{order_item['id']}", headers=headers)
    assert deleted.status_code == 200
    assert payment["amount"] == 9.0
