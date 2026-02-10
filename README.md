# Restaurant System Backend Baseline (Multi-tenant)

This baseline delivers two Python microservices:

- **portal-service (Reflex)**: tenant management + tenant-aware proxy to data service.
- **database-service (FastAPI + SQLite in-memory)**: tenant-scoped CRUD for restaurant core entities.

## Tenant propagation convention

We use the HTTP header **`X-Tenant-Id`** for tenant identity propagation.

Why header-based now:
- keeps URLs stable and resource-oriented,
- works for server-to-server and UI/API requests,
- easy to replace later with JWT-derived tenant claims.

## Services and structure

```text
.
├── portal_service/
│   ├── app.py
│   └── tenant_registry.py
├── database_service/
│   └── main.py
├── tests/
│   ├── test_database_service.py
│   └── test_portal_integration.py
├── ARCHITECTURE.md
└── rxconfig.py
```

## API contracts (v1)

### Error format

```json
{
  "error": "validation_error|invalid_tenant|not_found",
  "detail": "human-readable message"
}
```

### Portal service

- `POST /api/tenants` → create tenant
- `GET /api/tenants` → list tenants
- `GET /api/tenants/{tenant_id}` → get tenant
- `ANY /api/proxy/{resource...}` → proxy to database-service (requires `X-Tenant-Id`)

### Database service

All routes require `X-Tenant-Id`.

CRUD routes:
- `/v1/categories`
- `/v1/products`
- `/v1/tables`
- `/v1/tabs`
- `/v1/orders`
- `/v1/order-items`
- `/v1/payments`

Each supports:
- `POST /`
- `GET /`
- `GET /{id}`
- `PUT /{id}`
- `DELETE /{id}`

## Local setup

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r database-service/requirements.txt -r portal-service/requirements.txt -r requirements-dev.txt
```

## Run both services

Terminal 1 (database-service):

```bash
uvicorn database_service.main:app --host 0.0.0.0 --port 8001
```

Terminal 2 (portal-service API+UI):

```bash
DB_SERVICE_URL=http://127.0.0.1:8001 reflex run --backend-port 8000 --frontend-port 3000
```

## cURL examples

Create tenant via portal:

```bash
curl -s -X POST http://127.0.0.1:8000/api/tenants \
  -H 'Content-Type: application/json' \
  -d '{"name":"Tenant A"}'
```

Create category for tenant through portal proxy:

```bash
curl -s -X POST http://127.0.0.1:8000/api/proxy/categories \
  -H 'Content-Type: application/json' \
  -H 'X-Tenant-Id: <TENANT_ID>' \
  -d '{"name":"Food","description":"Main"}'
```

List products for tenant through portal proxy:

```bash
curl -s http://127.0.0.1:8000/api/proxy/products \
  -H 'X-Tenant-Id: <TENANT_ID>'
```

Direct database-service call:

```bash
curl -s http://127.0.0.1:8001/v1/categories -H 'X-Tenant-Id: <TENANT_ID>'
```

## Test suite

```bash
PYTHONPATH=. pytest -q
```

Covered scenarios:
- tenant A/B isolation on list/read,
- cross-tenant read/update/delete denied,
- CRUD lifecycle across Category/Product/Table/Tab/Order/OrderItem/Payment,
- integration test: portal tenant creation + portal proxy to database-service.

## Persistence migration note

Current database is `SQLite shared in-memory` (`file:tenantdb?mode=memory&cache=shared`).
To migrate later:
1. replace DSN with persistent SQLite/PostgreSQL,
2. introduce migrations (Alembic),
3. keep all repository methods tenant-aware (`tenant_id` mandatory),
4. add unique constraints indexed by `(tenant_id, business_key)`.
