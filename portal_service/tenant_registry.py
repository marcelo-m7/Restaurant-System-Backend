from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime, timezone
from threading import Lock
from uuid import uuid4


@dataclass
class Tenant:
    id: str
    name: str
    created_at: str


class TenantRegistry:
    def __init__(self) -> None:
        self._items: dict[str, Tenant] = {}
        self._lock = Lock()

    def create(self, name: str) -> Tenant:
        tenant_id = str(uuid4())
        tenant = Tenant(id=tenant_id, name=name.strip(), created_at=datetime.now(timezone.utc).isoformat())
        with self._lock:
            self._items[tenant_id] = tenant
        return tenant

    def list(self) -> list[Tenant]:
        with self._lock:
            return sorted(self._items.values(), key=lambda item: item.created_at)

    def get(self, tenant_id: str) -> Tenant | None:
        with self._lock:
            return self._items.get(tenant_id)


registry = TenantRegistry()
