import os

from fastapi.testclient import TestClient

os.environ["DB_SERVICE_URL"] = "http://db-service"

from database_service.main import app as db_app  # noqa: E402
from portal_service.app import app as portal_rx_app  # noqa: E402


portal_client = TestClient(portal_rx_app.api)
db_client = TestClient(db_app)


def test_portal_tenant_and_proxy_roundtrip(monkeypatch):
    tenant_resp = portal_client.post("/api/tenants", json={"name": "Alpha"})
    assert tenant_resp.status_code == 200
    tenant_id = tenant_resp.json()["id"]

    async def fake_request(self, method, url, **kwargs):
        path = url.replace("http://db-service", "")
        return db_client.request(method, path, **kwargs)

    import httpx

    monkeypatch.setattr(httpx.AsyncClient, "request", fake_request)

    create_category = portal_client.post(
        "/api/proxy/categories",
        headers={"X-Tenant-Id": tenant_id},
        json={"name": "Meals", "description": "Main"},
    )
    assert create_category.status_code == 200

    list_categories = portal_client.get("/api/proxy/categories", headers={"X-Tenant-Id": tenant_id})
    assert list_categories.status_code == 200
    assert len(list_categories.json()) == 1
