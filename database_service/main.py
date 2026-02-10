from __future__ import annotations

import sqlite3
from contextlib import contextmanager
from datetime import datetime, timezone
from typing import Any, Dict, Iterable, Optional

from fastapi import Depends, FastAPI, Header, HTTPException, Request
from pydantic import BaseModel, Field, field_validator


TENANT_HEADER = "X-Tenant-Id"


def utc_now() -> str:
    return datetime.now(timezone.utc).isoformat()


class ApiError(BaseModel):
    error: str
    detail: str


class CategoryIn(BaseModel):
    name: str = Field(min_length=1, max_length=100)
    description: str | None = Field(default=None, max_length=300)


class ProductIn(BaseModel):
    name: str = Field(min_length=1, max_length=100)
    price: float = Field(gt=0)
    category_id: int | None = None


class TableIn(BaseModel):
    name: str = Field(min_length=1, max_length=100)
    seats: int = Field(gt=0)
    status: str = Field(default="available", max_length=30)


class TabIn(BaseModel):
    table_id: int
    status: str = Field(default="open", max_length=30)


class OrderIn(BaseModel):
    tab_id: int
    status: str = Field(default="open", max_length=30)
    notes: str | None = Field(default=None, max_length=500)


class OrderItemIn(BaseModel):
    order_id: int
    product_id: int
    quantity: int = Field(gt=0)
    unit_price: float = Field(gt=0)


class PaymentIn(BaseModel):
    order_id: int
    amount: float = Field(gt=0)
    method: str = Field(min_length=1, max_length=30)
    status: str = Field(default="received", max_length=30)


class TenantContext(BaseModel):
    tenant_id: str

    @field_validator("tenant_id")
    @classmethod
    def validate_tenant_id(cls, value: str) -> str:
        if not value.strip():
            raise ValueError("tenant id cannot be empty")
        return value.strip()


class Database:
    def __init__(self) -> None:
        self.conn = sqlite3.connect(
            "file:tenantdb?mode=memory&cache=shared",
            uri=True,
            check_same_thread=False,
        )
        self.conn.row_factory = sqlite3.Row
        self._bootstrap()

    def _bootstrap(self) -> None:
        cur = self.conn.cursor()
        table_defs = {
            "categories": "name TEXT NOT NULL, description TEXT",
            "products": "name TEXT NOT NULL, price REAL NOT NULL, category_id INTEGER",
            "restaurant_tables": "name TEXT NOT NULL, seats INTEGER NOT NULL, status TEXT NOT NULL",
            "tabs": "table_id INTEGER NOT NULL, status TEXT NOT NULL, opened_at TEXT NOT NULL",
            "orders": "tab_id INTEGER NOT NULL, status TEXT NOT NULL, notes TEXT",
            "order_items": "order_id INTEGER NOT NULL, product_id INTEGER NOT NULL, quantity INTEGER NOT NULL, unit_price REAL NOT NULL",
            "payments": "order_id INTEGER NOT NULL, amount REAL NOT NULL, method TEXT NOT NULL, status TEXT NOT NULL",
        }
        for table_name, columns in table_defs.items():
            cur.execute(
                f"""
                CREATE TABLE IF NOT EXISTS {table_name} (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    tenant_id TEXT NOT NULL,
                    {columns},
                    created_at TEXT NOT NULL,
                    updated_at TEXT NOT NULL
                )
                """
            )
            cur.execute(
                f"CREATE INDEX IF NOT EXISTS idx_{table_name}_tenant ON {table_name}(tenant_id)"
            )
        self.conn.commit()

    @contextmanager
    def cursor(self) -> Iterable[sqlite3.Cursor]:
        cur = self.conn.cursor()
        try:
            yield cur
            self.conn.commit()
        finally:
            cur.close()




RELATION_CHECKS: dict[str, list[tuple[str, str]]] = {
    "products": [("category_id", "categories")],
    "tabs": [("table_id", "restaurant_tables")],
    "orders": [("tab_id", "tabs")],
    "order_items": [("order_id", "orders"), ("product_id", "products")],
    "payments": [("order_id", "orders")],
}


def _assert_relation_ownership(cur: sqlite3.Cursor, fk_value: int | None, parent_table: str, tenant_id: str) -> None:
    if fk_value is None:
        return
    cur.execute(f"SELECT tenant_id FROM {parent_table} WHERE id = ?", (fk_value,))
    row = cur.fetchone()
    if not row:
        raise HTTPException(status_code=400, detail=f"related record not found in {parent_table}")
    if row["tenant_id"] != tenant_id:
        raise HTTPException(status_code=403, detail="cross-tenant relationship denied")


def validate_relations(table: str, data: Dict[str, Any], tenant_id: str) -> None:
    checks = RELATION_CHECKS.get(table, [])
    if not checks:
        return
    with DB.cursor() as cur:
        for field, parent_table in checks:
            _assert_relation_ownership(cur, data.get(field), parent_table, tenant_id)

DB = Database()
app = FastAPI(title="database-service", version="0.1.0")


@app.exception_handler(ValueError)
async def value_error_handler(_: Request, exc: ValueError):
    return fastapi_json_error(400, "validation_error", str(exc))


def fastapi_json_error(status_code: int, error: str, detail: str):
    from fastapi.responses import JSONResponse

    return JSONResponse(status_code=status_code, content=ApiError(error=error, detail=detail).model_dump())


def tenant_ctx(x_tenant_id: str = Header(alias=TENANT_HEADER)) -> TenantContext:
    try:
        return TenantContext(tenant_id=x_tenant_id)
    except Exception as exc:  # pydantic validation
        raise HTTPException(status_code=400, detail=f"invalid tenant header: {exc}") from exc


def to_dict(row: sqlite3.Row | None) -> Dict[str, Any] | None:
    return dict(row) if row else None


def create_record(table: str, data: Dict[str, Any], tenant_id: str) -> Dict[str, Any]:
    data = data.copy()
    validate_relations(table, data, tenant_id)
    now = utc_now()
    data.update({"tenant_id": tenant_id, "created_at": now, "updated_at": now})
    keys = ", ".join(data.keys())
    placeholders = ", ".join(["?"] * len(data))
    with DB.cursor() as cur:
        cur.execute(f"INSERT INTO {table} ({keys}) VALUES ({placeholders})", list(data.values()))
        record_id = cur.lastrowid
        cur.execute(f"SELECT * FROM {table} WHERE id = ?", (record_id,))
        return to_dict(cur.fetchone()) or {}


def list_records(table: str, tenant_id: str) -> list[Dict[str, Any]]:
    with DB.cursor() as cur:
        cur.execute(f"SELECT * FROM {table} WHERE tenant_id = ? ORDER BY id", (tenant_id,))
        return [dict(row) for row in cur.fetchall()]


def get_record_or_error(table: str, record_id: int, tenant_id: str) -> Dict[str, Any]:
    with DB.cursor() as cur:
        cur.execute(f"SELECT * FROM {table} WHERE id = ?", (record_id,))
        existing = cur.fetchone()
        if not existing:
            raise HTTPException(status_code=404, detail="record not found")
        if existing["tenant_id"] != tenant_id:
            raise HTTPException(status_code=403, detail="cross-tenant access denied")
        return dict(existing)


def update_record(table: str, record_id: int, data: Dict[str, Any], tenant_id: str) -> Dict[str, Any]:
    _ = get_record_or_error(table, record_id, tenant_id)
    updates = data.copy()
    validate_relations(table, updates, tenant_id)
    updates["updated_at"] = utc_now()
    set_clause = ", ".join([f"{k} = ?" for k in updates.keys()])
    values = list(updates.values()) + [record_id]
    with DB.cursor() as cur:
        cur.execute(f"UPDATE {table} SET {set_clause} WHERE id = ?", values)
        cur.execute(f"SELECT * FROM {table} WHERE id = ?", (record_id,))
        return to_dict(cur.fetchone()) or {}


def delete_record(table: str, record_id: int, tenant_id: str) -> None:
    _ = get_record_or_error(table, record_id, tenant_id)
    with DB.cursor() as cur:
        cur.execute(f"DELETE FROM {table} WHERE id = ?", (record_id,))


def register_crud(path: str, table: str, schema: type[BaseModel]) -> None:
    @app.post(f"/v1/{path}")
    def create(payload: schema, tenant: TenantContext = Depends(tenant_ctx)):
        return create_record(table, payload.model_dump(), tenant.tenant_id)

    @app.get(f"/v1/{path}")
    def list_all(tenant: TenantContext = Depends(tenant_ctx)):
        return list_records(table, tenant.tenant_id)

    @app.get(f"/v1/{path}/{{record_id}}")
    def get_one(record_id: int, tenant: TenantContext = Depends(tenant_ctx)):
        return get_record_or_error(table, record_id, tenant.tenant_id)

    @app.put(f"/v1/{path}/{{record_id}}")
    def put_one(record_id: int, payload: schema, tenant: TenantContext = Depends(tenant_ctx)):
        return update_record(table, record_id, payload.model_dump(), tenant.tenant_id)

    @app.delete(f"/v1/{path}/{{record_id}}", status_code=204)
    def del_one(record_id: int, tenant: TenantContext = Depends(tenant_ctx)):
        delete_record(table, record_id, tenant.tenant_id)


register_crud("categories", "categories", CategoryIn)
register_crud("products", "products", ProductIn)
register_crud("tables", "restaurant_tables", TableIn)
register_crud("tabs", "tabs", TabIn)
register_crud("orders", "orders", OrderIn)
register_crud("order-items", "order_items", OrderItemIn)
register_crud("payments", "payments", PaymentIn)
