from __future__ import annotations

from typing import Any, cast

import httpx
from fastapi.testclient import TestClient

from services.database_service.app import create_db_app
from services.portal_service.app import create_portal_app


def test_portal_forwards_tenant_context_to_database_service() -> None:
    db_app = create_db_app()
    db_transport = httpx.ASGITransport(app=db_app)

    portal = create_portal_app(db_base_url="http://db", transport=db_transport)
    client = TestClient(cast(Any, portal).api)

    tenant = client.post("/api/tenants", json={"name": "Tenant One"}).json()["data"]
    headers = {"X-Tenant-ID": tenant["id"]}

    created = client.post(
        "/api/products", headers=headers, json={"data": {"name": "Soup", "price": 6.5}}
    )
    assert created.status_code == 200

    visible = client.get("/api/products", headers=headers)
    assert len(visible.json()["items"]) == 1

    other_visible = client.get("/api/products", headers={"X-Tenant-ID": "other-tenant"})
    assert other_visible.json()["items"] == []


def test_missing_tenant_header_is_blocked_on_proxy() -> None:
    portal = create_portal_app(
        db_base_url="http://db", transport=httpx.ASGITransport(app=create_db_app())
    )
    client = TestClient(cast(Any, portal).api)

    response = client.get("/api/products")
    assert response.status_code == 400
    assert response.json()["detail"]["error"] == "MISSING_TENANT"


def test_portal_rejects_invalid_json_body_for_proxy_post() -> None:
    portal = create_portal_app(
        db_base_url="http://db", transport=httpx.ASGITransport(app=create_db_app())
    )
    client = TestClient(cast(Any, portal).api)

    response = client.post(
        "/api/products",
        headers={"X-Tenant-ID": "tenant-json", "Content-Type": "application/json"},
        content='{"data": ',
    )

    assert response.status_code == 400
    assert response.json()["detail"]["error"] == "INVALID_JSON"
