# API Reference

## Headers

- `X-Tenant-ID`: required for all domain operations.

## Portal service (`:8000`)

### Health
- `GET /health` -> `{"status":"ok"}`

### Tenant registry
- `POST /tenants`
  - Request: `{"name":"Tenant A"}`
  - Response `201`: `{"tenant_id":"...","name":"Tenant A"}`
- `GET /tenants`
- `GET /tenants/{tenant_id}`

### Proxy
- `GET|POST|PUT|DELETE /api/{path}` forwards to database-service.

## Database service (`:8001`)

### Health
- `GET /health`

### Generic CRUD endpoints
For entity in `categories|products|units|areas|users|tables|tabs`:
- `POST /{entity}`
- `GET /{entity}`
- `GET /{entity}/{id}`
- `PUT /{entity}/{id}`
- `DELETE /{entity}/{id}`

### Domain endpoints
- `POST /tabs/open`
- `POST /orders`
- `POST /order-items`
- `POST /orders/{order_id}/send`
- `POST /order-items/{item_id}/void`
- `POST /tabs/{tab_id}/recalculate`
- `POST /payments`
- `POST /payments/{payment_id}/confirm`
- `POST /tabs/{tab_id}/close`

## Example requests

```bash
curl -sX POST http://127.0.0.1:8001/categories \
  -H 'content-type: application/json' \
  -H 'X-Tenant-ID: tenant-a' \
  -d '{"name":"Main"}'
```

```bash
curl -sX POST http://127.0.0.1:8001/tabs/open \
  -H 'content-type: application/json' \
  -H 'X-Tenant-ID: tenant-a' \
  -d '{"unit_id":1,"table_id":1}'
```

## Error response format

Application errors:

```json
{"error":"missing_tenant","detail":"X-Tenant-ID header required"}
```

Common statuses:
- `400`: missing tenant header
- `403`: unknown tenant (portal)
- `404`: not found / cross-tenant access
- `409`: business rule conflicts
- `422`: payload validation
