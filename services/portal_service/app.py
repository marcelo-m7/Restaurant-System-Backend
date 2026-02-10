from __future__ import annotations

import json
from datetime import datetime, timezone
from typing import Any
from uuid import uuid4

import httpx
import reflex as rx
from fastapi import HTTPException, Request
from pydantic import BaseModel, Field

from services.portal_service.client import DatabaseServiceClient


class TenantCreate(BaseModel):
    name: str = Field(min_length=2, max_length=80)


class TenantRecord(BaseModel):
    id: str
    name: str
    created_at: datetime


def create_portal_app(db_base_url: str = "http://127.0.0.1:8001", transport: httpx.AsyncBaseTransport | None = None) -> rx.App:
    tenants: dict[str, TenantRecord] = {}
    db_client = DatabaseServiceClient(base_url=db_base_url, transport=transport)

    class PortalState(rx.State):
        tenant_id: str = ""
        entity: str = "products"
        payload: str = '{"name": "Espresso", "price": 3.5}'
        response_text: str = ""

        async def create_demo_item(self):
            if not self.tenant_id:
                self.response_text = "Set tenant id first"
                return
            try:
                body = {"data": json.loads(self.payload)}
                data = await db_client.request("POST", f"/v1/{self.entity}", self.tenant_id, body)
                self.response_text = str(data)
            except Exception as exc:  # noqa: BLE001
                self.response_text = f"Error: {exc}"

        async def list_demo_items(self):
            if not self.tenant_id:
                self.response_text = "Set tenant id first"
                return
            try:
                data = await db_client.request("GET", f"/v1/{self.entity}", self.tenant_id)
                self.response_text = str(data)
            except Exception as exc:  # noqa: BLE001
                self.response_text = f"Error: {exc}"

    def index() -> rx.Component:
        return rx.container(
            rx.vstack(
                rx.heading("Restaurant Portal Service (Reflex)", size="6"),
                rx.text("Tenant is propagated using X-Tenant-ID header for explicit scope control."),
                rx.input(placeholder="Tenant ID", value=PortalState.tenant_id, on_change=PortalState.set_tenant_id),
                rx.select(
                    ["categories", "products", "tables", "tabs", "orders", "order-items", "payments"],
                    value=PortalState.entity,
                    on_change=PortalState.set_entity,
                ),
                rx.text_area(value=PortalState.payload, on_change=PortalState.set_payload, min_height="120px"),
                rx.hstack(
                    rx.button("Create", on_click=PortalState.create_demo_item),
                    rx.button("List", on_click=PortalState.list_demo_items),
                ),
                rx.code_block(PortalState.response_text),
                spacing="4",
            ),
            padding="2rem",
        )

    app = rx.App()
    app.add_page(index, route="/")

    @app.api.middleware("http")
    async def tenant_context_middleware(request: Request, call_next):
        request.state.tenant_id = request.headers.get("X-Tenant-ID")
        return await call_next(request)

    def get_tenant_from_request(request: Request) -> str:
        tenant_id = getattr(request.state, "tenant_id", None)
        if not tenant_id:
            raise HTTPException(status_code=400, detail={"error": "MISSING_TENANT", "message": "X-Tenant-ID required"})
        return tenant_id

    async def proxy_to_db(method: str, path: str, tenant_id: str, payload: dict[str, Any] | None = None) -> dict[str, Any]:
        try:
            return await db_client.request(method, path, tenant_id, payload)
        except httpx.HTTPStatusError as exc:
            raise HTTPException(status_code=exc.response.status_code, detail=exc.response.json()) from exc

    @app.api.post("/api/tenants")
    async def create_tenant(payload: TenantCreate) -> dict[str, Any]:
        tenant = TenantRecord(id=str(uuid4()), name=payload.name, created_at=datetime.now(timezone.utc))
        tenants[tenant.id] = tenant
        return {"data": tenant.model_dump(mode="json")}

    @app.api.get("/api/tenants")
    async def list_tenants() -> dict[str, Any]:
        return {"items": [tenant.model_dump(mode="json") for tenant in tenants.values()]}

    @app.api.get("/api/tenants/{tenant_id}")
    async def get_tenant(tenant_id: str) -> dict[str, Any]:
        tenant = tenants.get(tenant_id)
        if not tenant:
            raise HTTPException(status_code=404, detail={"error": "TENANT_NOT_FOUND", "message": "Tenant not found"})
        return {"data": tenant.model_dump(mode="json")}

    @app.api.api_route("/api/{entity}", methods=["GET", "POST"])
    async def proxy_entity_collection(entity: str, request: Request) -> dict[str, Any]:
        tenant_id = get_tenant_from_request(request)
        payload = await request.json() if request.method == "POST" else None
        return await proxy_to_db(request.method, f"/v1/{entity}", tenant_id, payload)

    @app.api.api_route("/api/{entity}/{item_id}", methods=["GET", "PUT", "DELETE"])
    async def proxy_entity_item(entity: str, item_id: str, request: Request) -> dict[str, Any]:
        tenant_id = get_tenant_from_request(request)
        payload = await request.json() if request.method == "PUT" else None
        return await proxy_to_db(request.method, f"/v1/{entity}/{item_id}", tenant_id, payload)

    return app


app = create_portal_app()
