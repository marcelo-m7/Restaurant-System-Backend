# Architecture - Multi-tenant Baseline

## Services

### 1) portal-service (Reflex + FastAPI API surface)
- Owns tenant registry lifecycle (`POST /tenants`, `GET /tenants`, `GET /tenants/{tenant_id}`)
- Resolves tenant identity from `X-Tenant-ID` header (chosen for explicitness and compatibility with API gateway/header injection strategies)
- Rejects unknown or missing tenant identifiers before forwarding requests
- Proxies tenant-scoped CRUD operations to database-service under `/api/*`

### 2) database-service (FastAPI + in-memory SQLite)
- Owns domain persistence and CRUD endpoints
- Contains all tables with explicit `tenant_id` column
- Enforces strict `tenant_id` filter on every CRUD query
- Returns `404 resource_not_found` when a resource exists for another tenant to prevent data leakage

## Tenant Propagation Convention
- Header key: `X-Tenant-ID`
- Required for all entity CRUD operations
- Optional/not required for tenant registry endpoints in portal-service

## Entity Set
- Category
- Product
- Table
- Tab
- Order
- OrderItem
- Payment

## Error Contract
Errors follow:

```json
{
  "error": "string_code",
  "detail": "human_readable_message"
}
```

Common codes:
- `missing_tenant`
- `unknown_tenant`
- `resource_not_found`
- `entity_not_found`
- `tenant_not_found`

## Persistent DB migration notes
Replace in-memory SQLite with persistent storage by:
1. Switching connection from `:memory:` to a file or server DSN.
2. Adding migrations (Alembic or SQL scripts).
3. Preserving all tenant predicates (`WHERE tenant_id = :tenant_id`) in repository/query layer.
4. Introducing per-tenant indexes (for example, `CREATE INDEX idx_products_tenant_id ON products(tenant_id)`).
