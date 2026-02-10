from __future__ import annotations

import os
from typing import Any

import httpx
import reflex as rx
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field

from .tenant_registry import registry

TENANT_HEADER = "X-Tenant-Id"
DB_SERVICE_URL = os.getenv("DB_SERVICE_URL", "http://127.0.0.1:8001")


class TenantCreate(BaseModel):
    name: str = Field(min_length=1, max_length=100)


class TenantOut(BaseModel):
    id: str
    name: str
    created_at: str


class AppState(rx.State):
    tenant_name: str = ""
    selected_tenant_id: str = ""
    category_name: str = ""
    product_name: str = ""
    product_price: str = "9.99"
    status_message: str = ""
    tenants: list[dict[str, str]] = []
    categories: list[dict[str, Any]] = []
    products: list[dict[str, Any]] = []

    def set_tenant_name(self, value: str):
        self.tenant_name = value

    def set_selected_tenant(self, value: str):
        self.selected_tenant_id = value

    def set_category_name(self, value: str):
        self.category_name = value

    def set_product_name(self, value: str):
        self.product_name = value

    def set_product_price(self, value: str):
        self.product_price = value

    async def create_tenant(self):
        if not self.tenant_name.strip():
            self.status_message = "Tenant name is required."
            return
        tenant = registry.create(self.tenant_name)
        self.status_message = f"Tenant created: {tenant.id}"
        self.tenant_name = ""
        await self.refresh_tenants()

    async def refresh_tenants(self):
        self.tenants = [TenantOut(**tenant.__dict__).model_dump() for tenant in registry.list()]
        if not self.selected_tenant_id and self.tenants:
            self.selected_tenant_id = self.tenants[0]["id"]

    async def create_category(self):
        if not self.selected_tenant_id:
            self.status_message = "Pick a tenant first."
            return
        payload = {"name": self.category_name, "description": "Default"}
        async with httpx.AsyncClient(timeout=5.0) as client:
            response = await client.post(
                f"{DB_SERVICE_URL}/v1/categories",
                json=payload,
                headers={TENANT_HEADER: self.selected_tenant_id},
            )
        if response.status_code >= 400:
            self.status_message = f"Category create failed: {response.text}"
            return
        self.status_message = "Category created"
        self.category_name = ""
        await self.refresh_categories()

    async def create_product(self):
        if not self.selected_tenant_id:
            self.status_message = "Pick a tenant first."
            return
        if not self.categories:
            self.status_message = "Create a category first."
            return
        payload = {
            "name": self.product_name,
            "price": float(self.product_price),
            "category_id": self.categories[0]["id"],
        }
        async with httpx.AsyncClient(timeout=5.0) as client:
            response = await client.post(
                f"{DB_SERVICE_URL}/v1/products",
                json=payload,
                headers={TENANT_HEADER: self.selected_tenant_id},
            )
        if response.status_code >= 400:
            self.status_message = f"Product create failed: {response.text}"
            return
        self.status_message = "Product created"
        self.product_name = ""
        await self.refresh_products()

    async def refresh_categories(self):
        if not self.selected_tenant_id:
            return
        async with httpx.AsyncClient(timeout=5.0) as client:
            response = await client.get(
                f"{DB_SERVICE_URL}/v1/categories",
                headers={TENANT_HEADER: self.selected_tenant_id},
            )
        self.categories = response.json() if response.status_code == 200 else []

    async def refresh_products(self):
        if not self.selected_tenant_id:
            return
        async with httpx.AsyncClient(timeout=5.0) as client:
            response = await client.get(
                f"{DB_SERVICE_URL}/v1/products",
                headers={TENANT_HEADER: self.selected_tenant_id},
            )
        self.products = response.json() if response.status_code == 200 else []

    async def refresh_all(self):
        await self.refresh_tenants()
        await self.refresh_categories()
        await self.refresh_products()


def tenant_card(tenant: dict[str, str]) -> rx.Component:
    return rx.box(rx.text(f"{tenant['name']} ({tenant['id'][:8]})"), border="1px solid #ddd", padding="0.5rem")


@rx.page(route="/")
def index() -> rx.Component:
    return rx.container(
        rx.vstack(
            rx.heading("Restaurant Portal Service", size="6"),
            rx.text("Tenant identity convention: X-Tenant-Id header"),
            rx.hstack(
                rx.input(value=AppState.tenant_name, on_change=AppState.set_tenant_name, placeholder="Tenant name"),
                rx.button("Create tenant", on_click=AppState.create_tenant),
                rx.button("Refresh", on_click=AppState.refresh_all),
            ),
            rx.select(
                [tenant["id"] for tenant in AppState.tenants],
                value=AppState.selected_tenant_id,
                on_change=AppState.set_selected_tenant,
                placeholder="Select tenant",
            ),
            rx.hstack(
                rx.input(value=AppState.category_name, on_change=AppState.set_category_name, placeholder="Category"),
                rx.button("Create category", on_click=AppState.create_category),
            ),
            rx.hstack(
                rx.input(value=AppState.product_name, on_change=AppState.set_product_name, placeholder="Product"),
                rx.input(value=AppState.product_price, on_change=AppState.set_product_price, placeholder="Price"),
                rx.button("Create product", on_click=AppState.create_product),
            ),
            rx.text(AppState.status_message),
            rx.divider(),
            rx.heading("Tenants", size="4"),
            rx.foreach(AppState.tenants, tenant_card),
            rx.heading("Products (selected tenant)", size="4"),
            rx.foreach(AppState.products, lambda item: rx.text(f"#{item['id']} {item['name']} ${item['price']}")),
            on_mount=AppState.refresh_all,
            align="stretch",
        ),
        max_width="900px",
        padding="2rem",
    )


app = rx.App()
app.add_page(index)


@app.api.post("/api/tenants")
async def create_tenant_api(payload: TenantCreate):
    tenant = registry.create(payload.name)
    return TenantOut(**tenant.__dict__).model_dump()


@app.api.get("/api/tenants")
async def list_tenants_api():
    return [TenantOut(**tenant.__dict__).model_dump() for tenant in registry.list()]


@app.api.get("/api/tenants/{tenant_id}")
async def get_tenant_api(tenant_id: str):
    tenant = registry.get(tenant_id)
    if not tenant:
        return JSONResponse(status_code=404, content={"error": "not_found", "detail": "tenant not found"})
    return TenantOut(**tenant.__dict__).model_dump()


@app.api.middleware("http")
async def tenant_context_middleware(request, call_next):
    if request.url.path.startswith("/api/proxy"):
        tenant_id = request.headers.get(TENANT_HEADER)
        if not tenant_id or not registry.get(tenant_id):
            return JSONResponse(status_code=400, content={"error": "invalid_tenant", "detail": "unknown tenant"})
        request.state.tenant_id = tenant_id
    return await call_next(request)


@app.api.api_route("/api/proxy/{resource:path}", methods=["GET", "POST", "PUT", "DELETE"])
async def proxy_to_db(request, resource: str):
    tenant_id = request.state.tenant_id
    url = f"{DB_SERVICE_URL}/v1/{resource}"
    body = await request.body()
    async with httpx.AsyncClient(timeout=5.0) as client:
        response = await client.request(
            request.method,
            url,
            content=body,
            params=request.query_params,
            headers={TENANT_HEADER: tenant_id, "content-type": request.headers.get("content-type", "application/json")},
        )
    return JSONResponse(status_code=response.status_code, content=response.json() if response.content else None)
