from __future__ import annotations

import os
from dataclasses import dataclass
from typing import Any
from uuid import uuid4

import httpx
import reflex as rx
from fastapi import Depends, HTTPException, Request
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


class PortalState(rx.State):
    message: str = "Restaurant portal-service baseline running"


portal_app = rx.App()
portal_app.add_page(lambda: rx.vstack(rx.heading("Portal Service"), rx.text(PortalState.message)), route="/")
api = portal_app.api

api.state.config = PortalConfig()
api.state.tenants = TenantRegistry()


@api.exception_handler(HTTPException)
async def http_exception_handler(_request: Request, exc: HTTPException) -> JSONResponse:
    detail = exc.detail if isinstance(exc.detail, dict) else {"error": "http_error", "detail": str(exc.detail)}
    return JSONResponse(status_code=exc.status_code, content=detail)


async def resolve_tenant(request: Request) -> str:
    tenant_id = request.headers.get(TENANT_HEADER)
    if not tenant_id:
        raise HTTPException(status_code=400, detail={"error": "missing_tenant", "detail": f"{TENANT_HEADER} header required"})
    if not request.app.state.tenants.get(tenant_id):
        raise HTTPException(status_code=403, detail={"error": "unknown_tenant", "detail": "Tenant not registered in portal"})
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


@api.api_route("/api/{entity}", methods=["GET", "POST"])
async def proxy_collection(entity: str, request: Request, tenant_id: str = Depends(resolve_tenant)) -> Any:
    client = get_http_client()
    async with client:
        if request.method == "GET":
            response = await client.get(f"/{entity}", headers={TENANT_HEADER: tenant_id})
        else:
            payload = await request.json()
            response = await client.post(f"/{entity}", headers={TENANT_HEADER: tenant_id}, json=payload)
    return JSONResponse(status_code=response.status_code, content=response.json() if response.content else None)


@api.api_route("/api/{entity}/{item_id}", methods=["GET", "PUT", "DELETE"])
async def proxy_resource(entity: str, item_id: int, request: Request, tenant_id: str = Depends(resolve_tenant)) -> Any:
    client = get_http_client()
    async with client:
        headers = {TENANT_HEADER: tenant_id}
        if request.method == "GET":
            response = await client.get(f"/{entity}/{item_id}", headers=headers)
        elif request.method == "PUT":
            payload = await request.json()
            response = await client.put(f"/{entity}/{item_id}", headers=headers, json=payload)
        else:
            response = await client.delete(f"/{entity}/{item_id}", headers=headers)

    if response.status_code == 204:
        return JSONResponse(status_code=204, content=None)
    return JSONResponse(status_code=response.status_code, content=response.json() if response.content else None)
