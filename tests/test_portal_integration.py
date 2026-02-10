import httpx
from fastapi.testclient import TestClient

from services.database_service.main import create_app as create_db_app
from services.portal_service import main as portal_main


def test_portal_forwards_tenant_context_and_blocks_unknown_tenant() -> None:
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

    unknown_tenant_request = portal_client.get("/api/categories", headers={portal_main.TENANT_HEADER: "unknown"})
    assert unknown_tenant_request.status_code == 403

    category = portal_client.post(
        "/api/categories",
        headers={portal_main.TENANT_HEADER: tenant_id},
        json={"name": "Starters"},
    )
    assert category.status_code == 201
    category_id = category.json()["id"]

    product = portal_client.post(
        "/api/products",
        headers={portal_main.TENANT_HEADER: tenant_id},
        json={"name": "Soup", "price": 12.0, "category_id": category_id},
    )
    assert product.status_code == 201

    list_products = portal_client.get("/api/products", headers={portal_main.TENANT_HEADER: tenant_id})
    assert list_products.status_code == 200
    assert len(list_products.json()["items"]) == 1
