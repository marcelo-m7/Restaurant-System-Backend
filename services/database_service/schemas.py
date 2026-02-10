from __future__ import annotations

from datetime import datetime
from typing import Any

from pydantic import BaseModel, Field


class EntityPayload(BaseModel):
    data: dict[str, Any] = Field(default_factory=dict)


class EntityResponse(BaseModel):
    data: dict[str, Any]


class EntityListResponse(BaseModel):
    items: list[dict[str, Any]]


class APIError(BaseModel):
    error: str
    message: str
    details: dict[str, Any] | None = None
    timestamp: datetime
