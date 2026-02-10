from datetime import UTC, datetime
from json import JSONDecodeError
from typing import Any
from uuid import uuid4

import httpx
from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import HTMLResponse
from pydantic import BaseModel, Field

from services.portal_service.client import DatabaseServiceClient


class TenantCreate(BaseModel):
    name: str = Field(min_length=2, max_length=80)


class TenantRecord(BaseModel):
    id: str
    name: str
    created_at: datetime


class APIError(BaseModel):
    error: str
    message: str
    details: dict[str, Any] | None = None
    timestamp: datetime


def create_api_error(
    error: str, message: str, details: dict[str, Any] | None = None
) -> dict[str, Any]:
    """Create a standardized API error response."""
    return APIError(
        error=error,
        message=message,
        details=details,
        timestamp=datetime.now(UTC),
    ).model_dump(mode="json")


def create_portal_app(
    db_base_url: str = "http://127.0.0.1:8001",
    transport: httpx.AsyncBaseTransport | None = None,
) -> FastAPI:
    tenants: dict[str, TenantRecord] = {}
    db_client = DatabaseServiceClient(base_url=db_base_url, transport=transport)
    api = FastAPI(title="portal-service", version="0.1.0")

    @api.get("/", response_class=HTMLResponse)
    async def index() -> str:
        return """
        <html><body>
        <h1>Restaurant Portal Service</h1>
        <p>Use <code>/api/tenants</code> for tenant management.</p>
        <p>Use <code>/api/{entity}</code> routes with
        <code>X-Tenant-ID</code> for CRUD proxying.</p>
        </body></html>
        """

    @api.middleware("http")
    async def tenant_context_middleware(request: Request, call_next):
        request.state.tenant_id = request.headers.get("X-Tenant-ID")
        return await call_next(request)

    def get_tenant_from_request(request: Request) -> str:
        tenant_id = getattr(request.state, "tenant_id", None)
        if not tenant_id:
            raise HTTPException(
                status_code=400,
                detail=create_api_error("MISSING_TENANT", "X-Tenant-ID required"),
            )
        return tenant_id

    async def proxy_to_db(
        method: str,
        path: str,
        tenant_id: str,
        payload: dict[str, Any] | None = None,
    ) -> dict[str, Any]:
        try:
            return await db_client.request(method, path, tenant_id, payload)
        except httpx.HTTPStatusError as exc:
            try:
                detail = exc.response.json()
                # Unwrap double-nested detail from upstream FastAPI errors
                if isinstance(detail, dict) and "detail" in detail:
                    detail = detail["detail"]
            except ValueError:
                detail = create_api_error("UPSTREAM_ERROR", exc.response.text)
            raise HTTPException(status_code=exc.response.status_code, detail=detail) from exc

    @api.post("/api/tenants")
    async def create_tenant(payload: TenantCreate) -> dict[str, Any]:
        tenant = TenantRecord(
            id=str(uuid4()),
            name=payload.name,
            created_at=datetime.now(UTC),
        )
        tenants[tenant.id] = tenant
        return {"data": tenant.model_dump(mode="json")}

    @api.get("/api/tenants")
    async def list_tenants() -> dict[str, Any]:
        return {"items": [tenant.model_dump(mode="json") for tenant in tenants.values()]}

    @api.get("/api/tenants/{tenant_id}")
    async def get_tenant(tenant_id: str) -> dict[str, Any]:
        tenant = tenants.get(tenant_id)
        if not tenant:
            raise HTTPException(
                status_code=404,
                detail=create_api_error("TENANT_NOT_FOUND", "Tenant not found"),
            )
        return {"data": tenant.model_dump(mode="json")}

    @api.api_route("/api/{entity}", methods=["GET", "POST"])
    async def proxy_entity_collection(entity: str, request: Request) -> dict[str, Any]:
        tenant_id = get_tenant_from_request(request)
        if request.method == "POST":
            try:
                payload = await request.json()
            except JSONDecodeError as exc:
                raise HTTPException(
                    status_code=400,
                    detail=create_api_error("INVALID_JSON", "Request body must be valid JSON."),
                ) from exc
        else:
            payload = None
        return await proxy_to_db(request.method, f"/v1/{entity}", tenant_id, payload)

    @api.api_route("/api/{entity}/{item_id}", methods=["GET", "PUT", "DELETE"])
    async def proxy_entity_item(entity: str, item_id: str, request: Request) -> dict[str, Any]:
        tenant_id = get_tenant_from_request(request)
        if request.method == "PUT":
            try:
                payload = await request.json()
            except JSONDecodeError as exc:
                raise HTTPException(
                    status_code=400,
                    detail=create_api_error("INVALID_JSON", "Request body must be valid JSON."),
                ) from exc
        else:
            payload = None
        return await proxy_to_db(request.method, f"/v1/{entity}/{item_id}", tenant_id, payload)

    return api


app = create_portal_app()
