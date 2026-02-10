# Architecture - Baseline v1

## Overview

Two-service baseline for restaurant operations with strict multi-tenant isolation.

- **portal-service (Reflex):** tenant registration, tenant validation middleware, and proxying calls to database-service with tenant header propagation.
- **database-service (FastAPI + SQLite in-memory):** tenant-scoped CRUD for core entities and relationship ownership checks.

## Tenant model

- Tenant identity is carried in HTTP header: `X-Tenant-Id`.
- Portal validates tenant existence before forwarding proxy requests.
- Database service enforces tenant boundary on all CRUD operations:
  - list queries are always `WHERE tenant_id = ?`,
  - get/update/delete read record first, deny if `tenant_id` mismatch,
  - related entity ownership checks prevent cross-tenant FK references.

## Core entities (minimum)

- `Category`
- `Product`
- `Table`
- `Tab`
- `Order`
- `OrderItem`
- `Payment`

All include:
- `id`
- `tenant_id`
- timestamps (`created_at`, `updated_at`)

## API contract summary

### Portal
- `POST /api/tenants`
- `GET /api/tenants`
- `GET /api/tenants/{tenant_id}`
- `/api/proxy/{resource:path}` (GET/POST/PUT/DELETE)

### Database
- `/v1/{resource}` + `/v1/{resource}/{id}` CRUD for each core table.

## Isolation guarantees in v1

1. Missing tenant header => request rejected.
2. Unknown tenant at portal proxy => request rejected.
3. Cross-tenant record access => `403`.
4. Cross-tenant relationship linking (e.g., order item -> foreign tenant order/product) => `403`.

## Future evolution

- Replace in-memory SQLite with persistent DB.
- Introduce migration/versioning (Alembic).
- Move from raw header tenant identity to JWT claims + signed service auth.
- Add table-level optimistic locking and audit trails.
