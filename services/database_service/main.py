from __future__ import annotations

import sqlite3
import threading
from contextlib import contextmanager
from datetime import datetime, timezone
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


class UnitIn(StrictModel):
    name: str = Field(min_length=1, max_length=120)
    timezone: str = Field(min_length=1, max_length=80)
    service_fee_enabled: bool = False
    service_fee_percent: float = Field(default=0, ge=0, le=100)


class AreaIn(StrictModel):
    unit_id: int
    name: str = Field(min_length=1, max_length=120)
    sort_order: int = Field(default=0, ge=0)


class UserIn(StrictModel):
    name: str = Field(min_length=1, max_length=120)
    email: str = Field(min_length=3, max_length=240)
    status: Literal["active", "inactive"] = "active"
    roles: str = Field(default="staff", min_length=1, max_length=240)


class DiningTableIn(StrictModel):
    unit_id: int
    area_id: int
    name: str = Field(min_length=1, max_length=120)
    capacity: int = Field(ge=1, le=20)
    status: Literal["available", "occupied", "reserved"] = "available"


class TabIn(StrictModel):
    unit_id: int
    table_id: int
    status: Literal["open", "closed"] = "open"


class OpenTabIn(StrictModel):
    unit_id: int
    table_id: int


class OrderIn(StrictModel):
    tab_id: int


class OrderItemIn(StrictModel):
    order_id: int
    product_id: int
    quantity: int = Field(ge=1)


class PaymentIn(StrictModel):
    tab_id: int
    amount: float = Field(gt=0)
    method: Literal["cash", "card", "pix"]


ENTITY_TABLES: dict[str, tuple[str, type[StrictModel], list[str]]] = {
    "categories": ("categories", CategoryIn, ["name"]),
    "products": ("products", ProductIn, ["name", "price", "category_id"]),
    "units": ("units", UnitIn, ["name", "timezone", "service_fee_enabled", "service_fee_percent"]),
    "areas": ("areas", AreaIn, ["unit_id", "name", "sort_order"]),
    "users": ("users", UserIn, ["name", "email", "status", "roles"]),
    "tables": ("dining_tables", DiningTableIn, ["unit_id", "area_id", "name", "capacity", "status"]),
    "tabs": ("tabs", TabIn, ["unit_id", "table_id", "status"]),
}


class Database:
    def __init__(self) -> None:
        self._lock = threading.Lock()
        self._conn = sqlite3.connect(":memory:", check_same_thread=False)
        self._conn.row_factory = sqlite3.Row
        self._conn.execute("PRAGMA foreign_keys = ON")
        self.bootstrap()

    @contextmanager
    def session(self) -> Iterator[sqlite3.Connection]:
        with self._lock:
            try:
                yield self._conn
                self._conn.commit()
            except Exception:
                self._conn.rollback()
                raise

    def bootstrap(self) -> None:
        schema = """
        CREATE TABLE IF NOT EXISTS categories (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tenant_id TEXT NOT NULL,
            name TEXT NOT NULL
        );
        CREATE TABLE IF NOT EXISTS units (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tenant_id TEXT NOT NULL,
            name TEXT NOT NULL,
            timezone TEXT NOT NULL,
            service_fee_enabled INTEGER NOT NULL DEFAULT 0,
            service_fee_percent REAL NOT NULL DEFAULT 0
        );
        CREATE TABLE IF NOT EXISTS areas (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tenant_id TEXT NOT NULL,
            unit_id INTEGER NOT NULL,
            name TEXT NOT NULL,
            sort_order INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY(unit_id) REFERENCES units(id)
        );
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tenant_id TEXT NOT NULL,
            name TEXT NOT NULL,
            email TEXT NOT NULL,
            status TEXT NOT NULL,
            roles TEXT NOT NULL
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
            unit_id INTEGER NOT NULL,
            area_id INTEGER NOT NULL,
            name TEXT NOT NULL,
            capacity INTEGER NOT NULL,
            status TEXT NOT NULL,
            FOREIGN KEY(unit_id) REFERENCES units(id),
            FOREIGN KEY(area_id) REFERENCES areas(id)
        );
        CREATE TABLE IF NOT EXISTS tabs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tenant_id TEXT NOT NULL,
            unit_id INTEGER NOT NULL,
            table_id INTEGER NOT NULL,
            status TEXT NOT NULL,
            opened_at TEXT,
            closed_at TEXT,
            subtotal_amount REAL NOT NULL DEFAULT 0,
            service_fee_amount REAL NOT NULL DEFAULT 0,
            total_amount REAL NOT NULL DEFAULT 0,
            paid_amount REAL NOT NULL DEFAULT 0,
            due_amount REAL NOT NULL DEFAULT 0,
            FOREIGN KEY(unit_id) REFERENCES units(id),
            FOREIGN KEY(table_id) REFERENCES dining_tables(id)
        );
        CREATE TABLE IF NOT EXISTS orders (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tenant_id TEXT NOT NULL,
            tab_id INTEGER NOT NULL,
            status TEXT NOT NULL,
            created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
            sent_at TEXT,
            FOREIGN KEY(tab_id) REFERENCES tabs(id)
        );
        CREATE TABLE IF NOT EXISTS order_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tenant_id TEXT NOT NULL,
            order_id INTEGER NOT NULL,
            product_id INTEGER NOT NULL,
            product_name_snapshot TEXT NOT NULL,
            unit_price_snapshot REAL NOT NULL,
            quantity INTEGER NOT NULL,
            status TEXT NOT NULL DEFAULT 'active',
            voided_at TEXT,
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
            paid_at TEXT,
            FOREIGN KEY(tab_id) REFERENCES tabs(id)
        );
        """
        with self.session() as conn:
            conn.executescript(schema)


def utcnow() -> str:
    return datetime.now(tz=timezone.utc).isoformat()


def get_tenant_id(x_tenant_id: str | None = Header(default=None, alias=TenantHeader)) -> str:
    if not x_tenant_id:
        raise HTTPException(status_code=400, detail={"error": "missing_tenant", "detail": f"{TenantHeader} header required"})
    return x_tenant_id


def fetch_one(conn: sqlite3.Connection, query: str, args: tuple[Any, ...], error_detail: str) -> sqlite3.Row:
    row = conn.execute(query, args).fetchone()
    if not row:
        raise HTTPException(status_code=404, detail={"error": "resource_not_found", "detail": error_detail})
    return row


def recalc_tab(conn: sqlite3.Connection, tenant_id: str, tab_id: int) -> dict[str, Any]:
    tab = fetch_one(conn, "SELECT * FROM tabs WHERE id=? AND tenant_id=?", (tab_id, tenant_id), "Tab not found")
    unit = fetch_one(conn, "SELECT * FROM units WHERE id=? AND tenant_id=?", (tab["unit_id"], tenant_id), "Unit not found")

    subtotal = conn.execute(
        """
        SELECT COALESCE(SUM(oi.quantity * oi.unit_price_snapshot), 0)
        FROM order_items oi
        JOIN orders o ON o.id = oi.order_id
        WHERE o.tab_id = ? AND o.tenant_id = ? AND o.status = 'sent' AND oi.status != 'void'
        """,
        (tab_id, tenant_id),
    ).fetchone()[0]
    paid_amount = conn.execute(
        "SELECT COALESCE(SUM(amount), 0) FROM payments WHERE tab_id = ? AND tenant_id = ? AND status = 'paid'",
        (tab_id, tenant_id),
    ).fetchone()[0]

    service_fee_amount = subtotal * (unit["service_fee_percent"] / 100) if unit["service_fee_enabled"] else 0
    total_amount = subtotal + service_fee_amount
    due_amount = max(total_amount - paid_amount, 0)

    conn.execute(
        """
        UPDATE tabs
        SET subtotal_amount=?, service_fee_amount=?, total_amount=?, paid_amount=?, due_amount=?
        WHERE id=? AND tenant_id=?
        """,
        (subtotal, service_fee_amount, total_amount, paid_amount, due_amount, tab_id, tenant_id),
    )
    updated = fetch_one(conn, "SELECT * FROM tabs WHERE id=? AND tenant_id=?", (tab_id, tenant_id), "Tab not found")
    return dict(updated)


def create_app(db: Database | None = None) -> FastAPI:
    app = FastAPI(title="database-service", version="0.2.0")
    app.state.db = db or Database()

    @app.get("/health")
    def health() -> dict[str, str]:
        return {"status": "ok"}

    @app.post("/{entity}", status_code=status.HTTP_201_CREATED)
    def create_entity(entity: str, payload: dict[str, Any], tenant_id: str = Depends(get_tenant_id)) -> dict[str, Any]:
        definition = ENTITY_TABLES.get(entity)
        if not definition:
            raise HTTPException(status_code=404, detail={"error": "entity_not_found", "detail": entity})
        table_name, model, columns = definition
        validated = model.model_validate(payload)
        placeholders = ", ".join(["?"] * (len(columns) + 1))
        col_sql = ", ".join(["tenant_id", *columns])
        values = [tenant_id, *[getattr(validated, column) for column in columns]]

        with app.state.db.session() as conn:
            cursor = conn.execute(f"INSERT INTO {table_name} ({col_sql}) VALUES ({placeholders})", values)
            row = fetch_one(
                conn,
                f"SELECT * FROM {table_name} WHERE id = ? AND tenant_id = ?",
                (cursor.lastrowid, tenant_id),
                "No resource for tenant",
            )
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
            row = fetch_one(
                conn,
                f"SELECT * FROM {table_name} WHERE id = ? AND tenant_id = ?",
                (item_id, tenant_id),
                "No resource for tenant",
            )
        return dict(row)

    @app.put("/{entity}/{item_id}")
    def update_entity(entity: str, item_id: int, payload: dict[str, Any], tenant_id: str = Depends(get_tenant_id)) -> dict[str, Any]:
        definition = ENTITY_TABLES.get(entity)
        if not definition:
            raise HTTPException(status_code=404, detail={"error": "entity_not_found", "detail": entity})
        table_name, model, columns = definition
        validated = model.model_validate(payload)
        assignments = ", ".join([f"{col} = ?" for col in columns])
        values = [*[getattr(validated, column) for column in columns], item_id, tenant_id]

        with app.state.db.session() as conn:
            cursor = conn.execute(f"UPDATE {table_name} SET {assignments} WHERE id = ? AND tenant_id = ?", values)
            if cursor.rowcount == 0:
                raise HTTPException(status_code=404, detail={"error": "resource_not_found", "detail": "No resource for tenant"})
            row = fetch_one(conn, f"SELECT * FROM {table_name} WHERE id = ? AND tenant_id = ?", (item_id, tenant_id), "No resource for tenant")
        return dict(row)

    @app.delete("/{entity}/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
    def delete_entity(entity: str, item_id: int, tenant_id: str = Depends(get_tenant_id)) -> Response:
        definition = ENTITY_TABLES.get(entity)
        if not definition:
            raise HTTPException(status_code=404, detail={"error": "entity_not_found", "detail": entity})
        table_name = definition[0]
        with app.state.db.session() as conn:
            cursor = conn.execute(f"DELETE FROM {table_name} WHERE id = ? AND tenant_id = ?", (item_id, tenant_id))
            if cursor.rowcount == 0:
                raise HTTPException(status_code=404, detail={"error": "resource_not_found", "detail": "No resource for tenant"})
        return Response(status_code=status.HTTP_204_NO_CONTENT)

    @app.post("/tabs/open", status_code=201)
    def open_tab(payload: OpenTabIn, tenant_id: str = Depends(get_tenant_id)) -> dict[str, Any]:
        with app.state.db.session() as conn:
            fetch_one(conn, "SELECT * FROM dining_tables WHERE id=? AND tenant_id=?", (payload.table_id, tenant_id), "Table not found")
            open_tab_row = conn.execute(
                "SELECT id FROM tabs WHERE tenant_id=? AND table_id=? AND status='open'",
                (tenant_id, payload.table_id),
            ).fetchone()
            if open_tab_row:
                raise HTTPException(status_code=409, detail={"error": "tab_already_open", "detail": "Table already has an open tab"})
            cursor = conn.execute(
                "INSERT INTO tabs(tenant_id, unit_id, table_id, status, opened_at, due_amount) VALUES (?, ?, ?, 'open', ?, 0)",
                (tenant_id, payload.unit_id, payload.table_id, utcnow()),
            )
            return dict(fetch_one(conn, "SELECT * FROM tabs WHERE id=? AND tenant_id=?", (cursor.lastrowid, tenant_id), "Tab not found"))

    @app.post("/orders", status_code=201)
    def create_order(payload: OrderIn, tenant_id: str = Depends(get_tenant_id)) -> dict[str, Any]:
        with app.state.db.session() as conn:
            tab = fetch_one(conn, "SELECT * FROM tabs WHERE id=? AND tenant_id=?", (payload.tab_id, tenant_id), "Tab not found")
            if tab["status"] != "open":
                raise HTTPException(status_code=409, detail={"error": "tab_closed", "detail": "Cannot add order to closed tab"})
            cursor = conn.execute(
                "INSERT INTO orders(tenant_id, tab_id, status) VALUES (?, ?, 'draft')",
                (tenant_id, payload.tab_id),
            )
            return dict(fetch_one(conn, "SELECT * FROM orders WHERE id=? AND tenant_id=?", (cursor.lastrowid, tenant_id), "Order not found"))

    @app.post("/order-items", status_code=201)
    def create_order_item(payload: OrderItemIn, tenant_id: str = Depends(get_tenant_id)) -> dict[str, Any]:
        with app.state.db.session() as conn:
            order = fetch_one(conn, "SELECT * FROM orders WHERE id=? AND tenant_id=?", (payload.order_id, tenant_id), "Order not found")
            if order["status"] != "draft":
                raise HTTPException(status_code=409, detail={"error": "order_immutable", "detail": "Only draft orders can receive items"})
            product = fetch_one(conn, "SELECT * FROM products WHERE id=? AND tenant_id=?", (payload.product_id, tenant_id), "Product not found")
            cursor = conn.execute(
                """
                INSERT INTO order_items(tenant_id, order_id, product_id, product_name_snapshot, unit_price_snapshot, quantity, status)
                VALUES (?, ?, ?, ?, ?, ?, 'active')
                """,
                (tenant_id, payload.order_id, payload.product_id, product["name"], product["price"], payload.quantity),
            )
            return dict(fetch_one(conn, "SELECT * FROM order_items WHERE id=? AND tenant_id=?", (cursor.lastrowid, tenant_id), "Item not found"))

    @app.post("/orders/{order_id}/send")
    def send_order(order_id: int, tenant_id: str = Depends(get_tenant_id)) -> dict[str, Any]:
        with app.state.db.session() as conn:
            order = fetch_one(conn, "SELECT * FROM orders WHERE id=? AND tenant_id=?", (order_id, tenant_id), "Order not found")
            if order["status"] != "draft":
                raise HTTPException(status_code=409, detail={"error": "order_immutable", "detail": "Order already sent"})
            item_count = conn.execute(
                "SELECT COUNT(*) FROM order_items WHERE order_id=? AND tenant_id=? AND status!='void'",
                (order_id, tenant_id),
            ).fetchone()[0]
            if item_count == 0:
                raise HTTPException(status_code=409, detail={"error": "order_empty", "detail": "Cannot send empty order"})
            conn.execute("UPDATE orders SET status='sent', sent_at=? WHERE id=? AND tenant_id=?", (utcnow(), order_id, tenant_id))
            return dict(fetch_one(conn, "SELECT * FROM orders WHERE id=? AND tenant_id=?", (order_id, tenant_id), "Order not found"))

    @app.post("/order-items/{item_id}/void")
    def void_item(item_id: int, tenant_id: str = Depends(get_tenant_id)) -> dict[str, Any]:
        with app.state.db.session() as conn:
            item = fetch_one(conn, "SELECT * FROM order_items WHERE id=? AND tenant_id=?", (item_id, tenant_id), "Item not found")
            if item["status"] == "void":
                return dict(item)
            order = fetch_one(conn, "SELECT * FROM orders WHERE id=? AND tenant_id=?", (item["order_id"], tenant_id), "Order not found")
            if order["status"] != "sent":
                raise HTTPException(status_code=409, detail={"error": "invalid_state", "detail": "Only sent order items can be voided"})
            conn.execute("UPDATE order_items SET status='void', voided_at=? WHERE id=? AND tenant_id=?", (utcnow(), item_id, tenant_id))
            recalc_tab(conn, tenant_id, order["tab_id"])
            return dict(fetch_one(conn, "SELECT * FROM order_items WHERE id=? AND tenant_id=?", (item_id, tenant_id), "Item not found"))

    @app.post("/tabs/{tab_id}/recalculate")
    def recalculate_tab(tab_id: int, tenant_id: str = Depends(get_tenant_id)) -> dict[str, Any]:
        with app.state.db.session() as conn:
            return recalc_tab(conn, tenant_id, tab_id)

    @app.post("/payments", status_code=201)
    def create_payment(payload: PaymentIn, tenant_id: str = Depends(get_tenant_id)) -> dict[str, Any]:
        with app.state.db.session() as conn:
            tab = fetch_one(conn, "SELECT * FROM tabs WHERE id=? AND tenant_id=?", (payload.tab_id, tenant_id), "Tab not found")
            if tab["status"] != "open":
                raise HTTPException(status_code=409, detail={"error": "tab_closed", "detail": "Cannot pay a closed tab"})
            recalc = recalc_tab(conn, tenant_id, payload.tab_id)
            if payload.amount > recalc["due_amount"]:
                raise HTTPException(status_code=409, detail={"error": "payment_exceeds_due", "detail": "Amount exceeds due amount"})
            cursor = conn.execute(
                "INSERT INTO payments(tenant_id, tab_id, amount, method, status) VALUES (?, ?, ?, ?, 'pending')",
                (tenant_id, payload.tab_id, payload.amount, payload.method),
            )
            return dict(fetch_one(conn, "SELECT * FROM payments WHERE id=? AND tenant_id=?", (cursor.lastrowid, tenant_id), "Payment not found"))

    @app.post("/payments/{payment_id}/confirm")
    def confirm_payment(payment_id: int, tenant_id: str = Depends(get_tenant_id)) -> dict[str, Any]:
        with app.state.db.session() as conn:
            payment = fetch_one(conn, "SELECT * FROM payments WHERE id=? AND tenant_id=?", (payment_id, tenant_id), "Payment not found")
            if payment["status"] == "paid":
                return dict(payment)
            conn.execute("UPDATE payments SET status='paid', paid_at=? WHERE id=? AND tenant_id=?", (utcnow(), payment_id, tenant_id))
            recalc_tab(conn, tenant_id, payment["tab_id"])
            return dict(fetch_one(conn, "SELECT * FROM payments WHERE id=? AND tenant_id=?", (payment_id, tenant_id), "Payment not found"))

    @app.post("/tabs/{tab_id}/close")
    def close_tab(tab_id: int, tenant_id: str = Depends(get_tenant_id)) -> dict[str, Any]:
        with app.state.db.session() as conn:
            tab = recalc_tab(conn, tenant_id, tab_id)
            if tab["status"] != "open":
                raise HTTPException(status_code=409, detail={"error": "tab_not_open", "detail": "Tab is not open"})
            pending_orders = conn.execute(
                "SELECT COUNT(*) FROM orders WHERE tab_id=? AND tenant_id=? AND status='draft'",
                (tab_id, tenant_id),
            ).fetchone()[0]
            if pending_orders > 0:
                raise HTTPException(status_code=409, detail={"error": "pending_orders", "detail": "Tab has draft orders"})
            if tab["due_amount"] > 0:
                raise HTTPException(status_code=409, detail={"error": "amount_due", "detail": "Tab has remaining due amount"})
            conn.execute("UPDATE tabs SET status='closed', closed_at=? WHERE id=? AND tenant_id=?", (utcnow(), tab_id, tenant_id))
            return dict(fetch_one(conn, "SELECT * FROM tabs WHERE id=? AND tenant_id=?", (tab_id, tenant_id), "Tab not found"))

    return app


app = create_app()
