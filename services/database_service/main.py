from __future__ import annotations

import sqlite3
import threading
from contextlib import contextmanager
from typing import Any, Iterator, Literal

from fastapi import Depends, FastAPI, Header, HTTPException, Response, status
from pydantic import BaseModel, ConfigDict, Field

TenantHeader = "X-Tenant-ID"


class APIError(BaseModel):
    error: str
    detail: str


class StrictModel(BaseModel):
    model_config = ConfigDict(extra="forbid")


class CategoryIn(StrictModel):
    name: str = Field(min_length=1, max_length=120)


class ProductIn(StrictModel):
    name: str = Field(min_length=1, max_length=120)
    price: float = Field(ge=0)
    category_id: int


class DiningTableIn(StrictModel):
    name: str = Field(min_length=1, max_length=120)
    seats: int = Field(ge=1, le=20)
    status: Literal["available", "occupied", "reserved"] = "available"


class TabIn(StrictModel):
    table_id: int
    status: Literal["open", "closed"] = "open"


class OrderIn(StrictModel):
    tab_id: int
    status: Literal["pending", "in_progress", "served", "cancelled"] = "pending"


class OrderItemIn(StrictModel):
    order_id: int
    product_id: int
    quantity: int = Field(ge=1)
    unit_price: float = Field(ge=0)


class PaymentIn(StrictModel):
    tab_id: int
    amount: float = Field(ge=0)
    method: Literal["cash", "card", "pix"]
    status: Literal["pending", "paid", "failed"] = "pending"


ENTITY_TABLES: dict[str, tuple[str, type[StrictModel], list[str]]] = {
    "categories": ("categories", CategoryIn, ["name"]),
    "products": ("products", ProductIn, ["name", "price", "category_id"]),
    "tables": ("dining_tables", DiningTableIn, ["name", "seats", "status"]),
    "tabs": ("tabs", TabIn, ["table_id", "status"]),
    "orders": ("orders", OrderIn, ["tab_id", "status"]),
    "order-items": ("order_items", OrderItemIn, ["order_id", "product_id", "quantity", "unit_price"]),
    "payments": ("payments", PaymentIn, ["tab_id", "amount", "method", "status"]),
}


class Database:
    def __init__(self) -> None:
        self._lock = threading.Lock()
        self._conn = sqlite3.connect(":memory:", check_same_thread=False)
        self._conn.row_factory = sqlite3.Row
        self.bootstrap()

    @contextmanager
    def session(self) -> Iterator[sqlite3.Connection]:
        with self._lock:
            yield self._conn
            self._conn.commit()

    def bootstrap(self) -> None:
        schema = """
        CREATE TABLE IF NOT EXISTS categories (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tenant_id TEXT NOT NULL,
            name TEXT NOT NULL
        );
        CREATE TABLE IF NOT EXISTS products (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tenant_id TEXT NOT NULL,
            name TEXT NOT NULL,
            price REAL NOT NULL,
            category_id INTEGER NOT NULL,
            FOREIGN KEY(category_id) REFERENCES categories(id)
        );
        CREATE TABLE IF NOT EXISTS dining_tables (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tenant_id TEXT NOT NULL,
            name TEXT NOT NULL,
            seats INTEGER NOT NULL,
            status TEXT NOT NULL
        );
        CREATE TABLE IF NOT EXISTS tabs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tenant_id TEXT NOT NULL,
            table_id INTEGER NOT NULL,
            status TEXT NOT NULL,
            FOREIGN KEY(table_id) REFERENCES dining_tables(id)
        );
        CREATE TABLE IF NOT EXISTS orders (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tenant_id TEXT NOT NULL,
            tab_id INTEGER NOT NULL,
            status TEXT NOT NULL,
            created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY(tab_id) REFERENCES tabs(id)
        );
        CREATE TABLE IF NOT EXISTS order_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tenant_id TEXT NOT NULL,
            order_id INTEGER NOT NULL,
            product_id INTEGER NOT NULL,
            quantity INTEGER NOT NULL,
            unit_price REAL NOT NULL,
            FOREIGN KEY(order_id) REFERENCES orders(id),
            FOREIGN KEY(product_id) REFERENCES products(id)
        );
        CREATE TABLE IF NOT EXISTS payments (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tenant_id TEXT NOT NULL,
            tab_id INTEGER NOT NULL,
            amount REAL NOT NULL,
            method TEXT NOT NULL,
            status TEXT NOT NULL,
            FOREIGN KEY(tab_id) REFERENCES tabs(id)
        );
        """
        with self.session() as conn:
            conn.executescript(schema)


def get_tenant_id(x_tenant_id: str | None = Header(default=None, alias=TenantHeader)) -> str:
    if not x_tenant_id:
        raise HTTPException(status_code=400, detail={"error": "missing_tenant", "detail": f"{TenantHeader} header required"})
    return x_tenant_id


def create_app(db: Database | None = None) -> FastAPI:
    app = FastAPI(title="database-service", version="0.1.0")
    app.state.db = db or Database()

    @app.get("/health")
    def health() -> dict[str, str]:
        return {"status": "ok"}

    @app.post("/{entity}", status_code=status.HTTP_201_CREATED)
    def create_entity(
        entity: str,
        payload: dict[str, Any],
        tenant_id: str = Depends(get_tenant_id),
    ) -> dict[str, Any]:
        definition = ENTITY_TABLES.get(entity)
        if not definition:
            raise HTTPException(status_code=404, detail={"error": "entity_not_found", "detail": entity})
        table_name, model, columns = definition
        validated = model.model_validate(payload)

        placeholders = ", ".join(["?"] * (len(columns) + 1))
        col_sql = ", ".join(["tenant_id", *columns])
        values = [tenant_id, *[getattr(validated, column) for column in columns]]
        query = f"INSERT INTO {table_name} ({col_sql}) VALUES ({placeholders})"

        with app.state.db.session() as conn:
            cursor = conn.execute(query, values)
            inserted_id = cursor.lastrowid
            row = conn.execute(
                f"SELECT * FROM {table_name} WHERE id = ? AND tenant_id = ?",
                (inserted_id, tenant_id),
            ).fetchone()
        return dict(row)

    @app.get("/{entity}")
    def list_entity(entity: str, tenant_id: str = Depends(get_tenant_id)) -> dict[str, list[dict[str, Any]]]:
        definition = ENTITY_TABLES.get(entity)
        if not definition:
            raise HTTPException(status_code=404, detail={"error": "entity_not_found", "detail": entity})
        table_name = definition[0]
        with app.state.db.session() as conn:
            rows = conn.execute(f"SELECT * FROM {table_name} WHERE tenant_id = ? ORDER BY id", (tenant_id,)).fetchall()
        return {"items": [dict(row) for row in rows]}

    @app.get("/{entity}/{item_id}")
    def get_entity(entity: str, item_id: int, tenant_id: str = Depends(get_tenant_id)) -> dict[str, Any]:
        definition = ENTITY_TABLES.get(entity)
        if not definition:
            raise HTTPException(status_code=404, detail={"error": "entity_not_found", "detail": entity})
        table_name = definition[0]
        with app.state.db.session() as conn:
            row = conn.execute(
                f"SELECT * FROM {table_name} WHERE id = ? AND tenant_id = ?", (item_id, tenant_id)
            ).fetchone()
        if not row:
            raise HTTPException(status_code=404, detail={"error": "resource_not_found", "detail": "No resource for tenant"})
        return dict(row)

    @app.put("/{entity}/{item_id}")
    def update_entity(
        entity: str,
        item_id: int,
        payload: dict[str, Any],
        tenant_id: str = Depends(get_tenant_id),
    ) -> dict[str, Any]:
        definition = ENTITY_TABLES.get(entity)
        if not definition:
            raise HTTPException(status_code=404, detail={"error": "entity_not_found", "detail": entity})
        table_name, model, columns = definition
        validated = model.model_validate(payload)

        assignments = ", ".join([f"{col} = ?" for col in columns])
        values = [*[getattr(validated, column) for column in columns], item_id, tenant_id]
        query = f"UPDATE {table_name} SET {assignments} WHERE id = ? AND tenant_id = ?"

        with app.state.db.session() as conn:
            cursor = conn.execute(query, values)
            if cursor.rowcount == 0:
                raise HTTPException(status_code=404, detail={"error": "resource_not_found", "detail": "No resource for tenant"})
            row = conn.execute(
                f"SELECT * FROM {table_name} WHERE id = ? AND tenant_id = ?",
                (item_id, tenant_id),
            ).fetchone()
        return dict(row)

    @app.delete("/{entity}/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
    def delete_entity(entity: str, item_id: int, tenant_id: str = Depends(get_tenant_id)) -> Response:
        definition = ENTITY_TABLES.get(entity)
        if not definition:
            raise HTTPException(status_code=404, detail={"error": "entity_not_found", "detail": entity})
        table_name = definition[0]
        with app.state.db.session() as conn:
            cursor = conn.execute(
                f"DELETE FROM {table_name} WHERE id = ? AND tenant_id = ?",
                (item_id, tenant_id),
            )
        if cursor.rowcount == 0:
            raise HTTPException(status_code=404, detail={"error": "resource_not_found", "detail": "No resource for tenant"})
        return Response(status_code=status.HTTP_204_NO_CONTENT)

    return app


app = create_app()
