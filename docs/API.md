# API Reference

## Tenant header

Tenant-owned routes require:

```http
X-Tenant-ID: <tenant-id>
```

## portal-service API (`:8000`)

### `POST /api/tenants`
Create tenant.

Request:
```json
{"name": "Tenant A"}
```

Response:
```json
{"data": {"id": "...", "name": "Tenant A", "created_at": "..."}}
```

### `GET /api/tenants`
List known tenants.

### `GET /api/tenants/{tenant_id}`
Get one tenant.

### `GET|POST /api/{entity}`
Proxy list/create to database-service.

### `GET|PUT|DELETE /api/{entity}/{item_id}`
Proxy get/update/delete to database-service.

## database-service API (`:8001`)

### `GET /health`
Health check.

### `POST /v1/{entity}`
Create entity using wrapper payload:

```json
{"data": {...}}
```

### `GET /v1/{entity}`
List entities in tenant scope.

### `GET /v1/{entity}/{item_id}`
Get entity in tenant scope.

### `PUT /v1/{entity}/{item_id}`
Update entity in tenant scope.

### `DELETE /v1/{entity}/{item_id}`
Delete entity in tenant scope.

## Error format

Most service errors are returned as:

```json
{
  "error": "ERROR_CODE",
  "message": "Human-readable explanation",
  "details": {},
  "timestamp": "2026-01-01T00:00:00Z"
}
```

Common errors:

- `MISSING_TENANT`
- `TENANT_SCOPE_VIOLATION`
- `INVALID_REFERENCE`
- `INVALID_PAYLOAD`
- `UNKNOWN_ENTITY`
- `INVALID_JSON`
