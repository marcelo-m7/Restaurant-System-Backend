import importlib

from fastapi.testclient import TestClient


def test_portal_config_uses_environment_variable(monkeypatch) -> None:
    monkeypatch.setenv("DATABASE_SERVICE_URL", "http://example-db:9999")
    from services.portal_service import main as portal_main

    reloaded = importlib.reload(portal_main)

    assert reloaded.PortalConfig().database_service_url == "http://example-db:9999"


def test_database_service_health_endpoint() -> None:
    from services.database_service.main import create_app

    client = TestClient(create_app())
    response = client.get("/health")

    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_portal_service_health_endpoint() -> None:
    from services.portal_service import main as portal_main

    client = TestClient(portal_main.api)
    response = client.get("/health")

    assert response.status_code == 200
    assert response.json() == {"status": "ok"}
