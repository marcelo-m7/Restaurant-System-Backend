# Architecture

## Service responsibilities

## database-service (`services/database_service`)

- Hosts tenant-scoped CRUD endpoints: `/v1/{entity}` and `/v1/{entity}/{id}`.
- Bootstraps schema at startup.
- Enforces tenant header with dependency (`X-Tenant-ID`).
- Enforces tenant isolation in all queries.
- Validates tenant-safe foreign-key references.

## portal-service (`services/portal_service`)

- Hosts tenant management endpoints:
  - `POST /api/tenants`
  - `GET /api/tenants`
  - `GET /api/tenants/{tenant_id}`
- Proxies CRUD to database-service while forwarding tenant header.
- Normalizes upstream HTTP errors and handles invalid JSON payloads.

## Request flow

1. Client sends request to portal endpoint.
2. Portal reads `X-Tenant-ID` from request middleware state.
3. Portal forwards request to database-service through HTTPX.
4. Database-service applies tenant filter in SQLAlchemy query.
5. Response returns through portal to caller.

## Data model overview

Entities:

- `categories`
- `products`
- `tables`
- `tabs`
- `orders`
- `order-items`
- `payments`

Shared columns on all models:

- `id`
- `tenant_id`
- `created_at`
- `updated_at`

## Design choices and tradeoffs

- **Header-based tenancy**: explicit and easy to trace, but clients must always set headers.
- **Generic entity routes**: compact service code, but weaker static typing per entity payload.
- **In-memory SQLite**: fast for tests/dev, but not persistent and not production-ready.
- **Portal in-memory tenant registry**: simple bootstrap, but ephemeral and not shared across instances.

## Security and correctness controls

- Tenant header required on all tenant-owned operations.
- Cross-tenant reads/updates/deletes blocked (`TENANT_SCOPE_VIOLATION`).
- Cross-tenant foreign-key links blocked (`INVALID_REFERENCE`).
- Unknown entities return structured error (`UNKNOWN_ENTITY`).
