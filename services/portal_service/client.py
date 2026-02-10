from __future__ import annotations

from typing import Any

import httpx


class DatabaseServiceClient:
    def __init__(self, base_url: str, transport: httpx.AsyncBaseTransport | None = None):
        self.base_url = base_url.rstrip("/")
        self.transport = transport

    async def request(
        self,
        method: str,
        path: str,
        tenant_id: str,
        json_body: dict[str, Any] | None = None,
    ) -> dict[str, Any]:
        headers = {"X-Tenant-ID": tenant_id}
        async with httpx.AsyncClient(
            base_url=self.base_url, headers=headers, transport=self.transport, timeout=10.0
        ) as client:
            response = await client.request(method, path, json=json_body)
            response.raise_for_status()
            return response.json()
