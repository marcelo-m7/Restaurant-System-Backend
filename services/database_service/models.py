from __future__ import annotations

from datetime import datetime, timezone
from typing import Any
from uuid import uuid4

from sqlalchemy import DateTime, Float, ForeignKey, Integer, String, Text
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column


class Base(DeclarativeBase):
    pass


class TenantScopedMixin:
    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid4()))
    tenant_id: Mapped[str] = mapped_column(String(64), index=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc)
    )


class Category(TenantScopedMixin, Base):
    __tablename__ = "categories"

    name: Mapped[str] = mapped_column(String(120), nullable=False)


class Product(TenantScopedMixin, Base):
    __tablename__ = "products"

    name: Mapped[str] = mapped_column(String(120), nullable=False)
    category_id: Mapped[str | None] = mapped_column(ForeignKey("categories.id"), nullable=True)
    price: Mapped[float] = mapped_column(Float, nullable=False)


class DiningTable(TenantScopedMixin, Base):
    __tablename__ = "tables"

    name: Mapped[str] = mapped_column(String(60), nullable=False)
    seats: Mapped[int] = mapped_column(Integer, nullable=False, default=2)


class Tab(TenantScopedMixin, Base):
    __tablename__ = "tabs"

    table_id: Mapped[str | None] = mapped_column(ForeignKey("tables.id"), nullable=True)
    status: Mapped[str] = mapped_column(String(32), default="open")


class Order(TenantScopedMixin, Base):
    __tablename__ = "orders"

    tab_id: Mapped[str | None] = mapped_column(ForeignKey("tabs.id"), nullable=True)
    status: Mapped[str] = mapped_column(String(32), default="pending")


class OrderItem(TenantScopedMixin, Base):
    __tablename__ = "order_items"

    order_id: Mapped[str] = mapped_column(ForeignKey("orders.id"), nullable=False)
    product_id: Mapped[str] = mapped_column(ForeignKey("products.id"), nullable=False)
    quantity: Mapped[int] = mapped_column(Integer, nullable=False, default=1)


class Payment(TenantScopedMixin, Base):
    __tablename__ = "payments"

    order_id: Mapped[str] = mapped_column(ForeignKey("orders.id"), nullable=False)
    amount: Mapped[float] = mapped_column(Float, nullable=False)
    method: Mapped[str] = mapped_column(String(32), nullable=False, default="cash")


ENTITY_MODELS: dict[str, type[Base]] = {
    "categories": Category,
    "products": Product,
    "tables": DiningTable,
    "tabs": Tab,
    "orders": Order,
    "order-items": OrderItem,
    "payments": Payment,
}


def serialize_model(instance: Base) -> dict[str, Any]:
    return {column.name: getattr(instance, column.name) for column in instance.__table__.columns}
