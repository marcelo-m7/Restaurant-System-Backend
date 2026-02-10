from __future__ import annotations

import os
from dataclasses import dataclass
from typing import Any
from uuid import uuid4

import httpx
import reflex as rx
from fastapi import Depends, FastAPI, HTTPException, Request
from fastapi.responses import JSONResponse
from pydantic import BaseModel, ConfigDict, Field

TENANT_HEADER = "X-Tenant-ID"


class StrictModel(BaseModel):
    model_config = ConfigDict(extra="forbid")


class TenantCreate(StrictModel):
    name: str = Field(min_length=1, max_length=100)


class TenantRecord(StrictModel):
    tenant_id: str
    name: str


@dataclass
class PortalConfig:
    database_service_url: str = os.getenv("DATABASE_SERVICE_URL", "http://127.0.0.1:8001")


class TenantRegistry:
    def __init__(self) -> None:
        self._tenants: dict[str, TenantRecord] = {}

    def create(self, name: str) -> TenantRecord:
        tenant = TenantRecord(tenant_id=str(uuid4()), name=name)
        self._tenants[tenant.tenant_id] = tenant
        return tenant

    def list(self) -> list[TenantRecord]:
        return list(self._tenants.values())

    def get(self, tenant_id: str) -> TenantRecord | None:
        return self._tenants.get(tenant_id)


portal_app = rx.App()


def home() -> rx.Component:
    return rx.vstack(
        rx.heading("Restaurant Portal"),
        rx.text("Restaurant portal-service running"),
        rx.hstack(
            rx.link("Units", href="/units"),
            rx.link("Areas", href="/areas"),
            rx.link("Tables", href="/tables"),
            rx.link("Products", href="/products"),
            rx.link("Orders", href="/orders"),
            rx.link("Payments", href="/payments"),
            rx.link("Tabs", href="/tabs"),
            spacing="4",
        ),
    )


def simple_form_page(title: str, field_name: str) -> rx.Component:
    return rx.vstack(
        rx.heading(title),
        rx.text("Simple management screen for domain flow testing."),
        rx.input(placeholder=field_name),
        rx.button("Submit"),
        rx.link("Back", href="/"),
    )


portal_app.add_page(home, route="/")
portal_app.add_page(lambda: simple_form_page("Units", "Unit name"), route="/units")
portal_app.add_page(lambda: simple_form_page("Areas", "Area name"), route="/areas")
portal_app.add_page(lambda: simple_form_page("Tables", "Table name"), route="/tables")
portal_app.add_page(lambda: simple_form_page("Products", "Product name"), route="/products")
portal_app.add_page(lambda: simple_form_page("Orders", "Order details"), route="/orders")
portal_app.add_page(lambda: simple_form_page("Payments", "Payment amount"), route="/payments")
portal_app.add_page(lambda: simple_form_page("Tabs", "Tab action"), route="/tabs")

api = FastAPI(title="portal-service", version="0.2.0")
api.state.config = PortalConfig()
api.state.tenants = TenantRegistry()


@api.exception_handler(HTTPException)
async def http_exception_handler(_request: Request, exc: HTTPException) -> JSONResponse:
    detail = exc.detail if isinstance(exc.detail, dict) else {"error": "http_error", "detail": str(exc.detail)}
    return JSONResponse(status_code=exc.status_code, content=detail)


async def resolve_tenant(request: Request) -> str:
    tenant_id = request.headers.get(TENANT_HEADER)
    if not tenant_id:
        raise HTTPException(
            status_code=400, detail={"error": "missing_tenant", "detail": f"{TENANT_HEADER} header required"}
        )
    if not request.app.state.tenants.get(tenant_id):
        raise HTTPException(
            status_code=403, detail={"error": "unknown_tenant", "detail": "Tenant not registered in portal"}
        )
    request.state.tenant_id = tenant_id
    return tenant_id


def get_http_client() -> httpx.AsyncClient:
    return httpx.AsyncClient(base_url=api.state.config.database_service_url, timeout=10.0)


@api.get("/health")
async def health() -> dict[str, str]:
    return {"status": "ok"}


@api.post("/tenants", response_model=TenantRecord, status_code=201)
async def create_tenant(payload: TenantCreate) -> TenantRecord:
    return api.state.tenants.create(payload.name)


@api.get("/tenants", response_model=list[TenantRecord])
async def list_tenants() -> list[TenantRecord]:
    return api.state.tenants.list()


@api.get("/tenants/{tenant_id}", response_model=TenantRecord)
async def get_tenant(tenant_id: str) -> TenantRecord:
    tenant = api.state.tenants.get(tenant_id)
    if not tenant:
        raise HTTPException(status_code=404, detail={"error": "tenant_not_found", "detail": tenant_id})
    return tenant


@api.api_route("/api/{path:path}", methods=["GET", "POST", "PUT", "DELETE"])
async def proxy_any(path: str, request: Request, tenant_id: str = Depends(resolve_tenant)) -> Any:
    client = get_http_client()
    async with client:
        headers = {TENANT_HEADER: tenant_id}
        body = await request.body()
        response = await client.request(
            method=request.method,
            url=f"/{path}",
            headers=headers,
            params=request.query_params,
            content=body if body else None,
        )

    if response.status_code == 204:
        return JSONResponse(status_code=204, content=None)
    return JSONResponse(status_code=response.status_code, content=response.json() if response.content else None)
