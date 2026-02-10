import httpx
from fastapi.testclient import TestClient

from services.database_service.main import create_app as create_db_app
from services.portal_service import main as portal_main


def test_portal_proxies_crud_and_domain_endpoints() -> None:
    db_app = create_db_app()
    transport = httpx.ASGITransport(app=db_app)

    def fake_client() -> httpx.AsyncClient:
        return httpx.AsyncClient(transport=transport, base_url="http://db")

    portal_main.api.state.tenants = portal_main.TenantRegistry()
    portal_main.get_http_client = fake_client

    portal_client = TestClient(portal_main.api)

    create_tenant_response = portal_client.post("/tenants", json={"name": "Tenant A"})
    assert create_tenant_response.status_code == 201
    tenant_id = create_tenant_response.json()["tenant_id"]
    headers = {portal_main.TENANT_HEADER: tenant_id}

    unknown_tenant_request = portal_client.get("/api/categories", headers={portal_main.TENANT_HEADER: "unknown"})
    assert unknown_tenant_request.status_code == 403

    category_id = portal_client.post("/api/categories", headers=headers, json={"name": "Main"}).json()["id"]
    product_id = portal_client.post(
        "/api/products", headers=headers, json={"name": "Soup", "price": 12.0, "category_id": category_id}
    ).json()["id"]
    unit_id = portal_client.post(
        "/api/units",
        headers=headers,
        json={"name": "Unit A", "timezone": "UTC", "service_fee_enabled": False, "service_fee_percent": 0},
    ).json()["id"]
    area_id = portal_client.post(
        "/api/areas", headers=headers, json={"unit_id": unit_id, "name": "Hall", "sort_order": 0}
    ).json()["id"]
    table_id = portal_client.post(
        "/api/tables",
        headers=headers,
        json={"unit_id": unit_id, "area_id": area_id, "name": "T1", "capacity": 2, "status": "available"},
    ).json()["id"]

    tab = portal_client.post("/api/tabs/open", headers=headers, json={"unit_id": unit_id, "table_id": table_id})
    assert tab.status_code == 201
    order = portal_client.post("/api/orders", headers=headers, json={"tab_id": tab.json()["id"]})
    assert order.status_code == 201
    order_id = order.json()["id"]

    item = portal_client.post(
        "/api/order-items", headers=headers, json={"order_id": order_id, "product_id": product_id, "quantity": 1}
    )
    assert item.status_code == 201
    send = portal_client.post(f"/api/orders/{order_id}/send", headers=headers)
    assert send.status_code == 200
