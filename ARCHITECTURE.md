# Architecture (Baseline v0.1)

## Services

### 1) portal-service (Reflex)

Responsibilities:
- Tenant registration/list/get (`/api/tenants`)
- Resolve tenant context from `X-Tenant-ID`
- Proxy tenant-scoped CRUD calls to database-service (`/api/{entity}`)
- Provide simple Reflex UI for manual smoke testing

Isolation guard:
- Middleware stores `request.state.tenant_id`
- Proxy handlers reject missing tenant header before forwarding

### 2) database-service (FastAPI + SQLite in-memory)

Responsibilities:
- Bootstrap schema on startup
- CRUD endpoints for: `categories`, `products`, `tables`, `tabs`, `orders`, `order-items`, `payments`
- Apply strict tenant filter in every list/get/update/delete path

Isolation guard:
- Mandatory `X-Tenant-ID` dependency
- Every query includes `model.tenant_id == tenant_id`
- Cross-tenant access returns `TENANT_SCOPE_VIOLATION`

## API contract

### Tenant propagation
- Header: `X-Tenant-ID: <tenant-uuid-or-slug>`
- Required on all tenant-scoped CRUD endpoints

### Portal API
- `POST /api/tenants` -> `{ data: { id, name, created_at } }`
- `GET /api/tenants` -> `{ items: [...] }`
- `GET /api/tenants/{tenant_id}` -> `{ data: ... }`
- `GET|POST /api/{entity}` -> proxied to database-service
- `GET|PUT|DELETE /api/{entity}/{id}` -> proxied to database-service

### Database API
- `POST /v1/{entity}` with `{ data: {...} }`
- `GET /v1/{entity}`
- `GET /v1/{entity}/{id}`
- `PUT /v1/{entity}/{id}` with `{ data: {...} }`
- `DELETE /v1/{entity}/{id}`

### Error format

```json
{
  "error": "TENANT_SCOPE_VIOLATION",
  "message": "Record not found for tenant scope.",
  "details": null,
  "timestamp": "2026-01-01T00:00:00Z"
}
```

## Data model notes

All core tables contain:
- `id`
- `tenant_id`
- `created_at`
- `updated_at`

This shared shape makes tenant filtering uniform and hard to bypass in normal API usage.

## Persistence migration path

To move from in-memory SQLite:
1. Replace SQLAlchemy URL with persistent SQLite/PostgreSQL.
2. Introduce Alembic migrations.
3. Keep tenant filter contract unchanged.
4. Add DB-level constraints/indexes (`tenant_id`, composite uniques).
