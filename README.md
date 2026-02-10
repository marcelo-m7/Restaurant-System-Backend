# Restaurant System Backend - Multi-tenant Runnable Baseline

This repository now contains a runnable two-service baseline:

- `portal-service`: Reflex app + FastAPI routes for tenant registration and tenant-aware proxying.
- `database-service`: FastAPI service with in-memory SQLite and tenant-scoped CRUD.

## Project structure

```text
.
├── services/
│   ├── portal_service/
│   │   └── main.py
│   └── database_service/
│       └── main.py
├── tests/
│   ├── test_database_service.py
│   └── test_portal_integration.py
├── ARCHITECTURE.md
├── README.md
└── pyproject.toml
```

## API contracts

Tenant propagation convention:
- Header: `X-Tenant-ID`
- Required for CRUD on entity endpoints.

Error format:

```json
{
  "error": "string_code",
  "detail": "human_readable_message"
}
```

Entity endpoints (database-service, proxied by portal-service under `/api`):
- `categories`
- `products`
- `tables`
- `tabs`
- `orders`
- `order-items`
- `payments`

CRUD pattern:
- `POST /{entity}`
- `GET /{entity}`
- `GET /{entity}/{id}`
- `PUT /{entity}/{id}`
- `DELETE /{entity}/{id}`

## Local setup

```bash
python -m venv .venv
source .venv/bin/activate
pip install -e .[dev]
```

## Run services

Terminal 1 (database-service):

```bash
uvicorn services.database_service.main:app --host 0.0.0.0 --port 8001 --reload
```

Terminal 2 (portal-service API + Reflex backend):

```bash
DATABASE_SERVICE_URL=http://127.0.0.1:8001 uvicorn services.portal_service.main:api --host 0.0.0.0 --port 8000 --reload
```

Optional Reflex UI dev server:

```bash
reflex run
```

## Example flow

### 1) Create tenant in portal-service

```bash
curl -s -X POST http://127.0.0.1:8000/tenants \
  -H 'content-type: application/json' \
  -d '{"name":"Tenant A"}'
```

Capture `tenant_id` from response.

### 2) Tenant-scoped category CRUD via portal-service proxy

```bash
TENANT_ID="<tenant-id-from-previous-step>"

curl -s -X POST http://127.0.0.1:8000/api/categories \
  -H "X-Tenant-ID: ${TENANT_ID}" \
  -H 'content-type: application/json' \
  -d '{"name":"Burgers"}'

curl -s http://127.0.0.1:8000/api/categories \
  -H "X-Tenant-ID: ${TENANT_ID}"
```

### 3) Cross-tenant read is blocked

```bash
curl -s http://127.0.0.1:8000/api/categories/1 \
  -H "X-Tenant-ID: some-other-tenant"
```

Expected response:

```json
{"error":"unknown_tenant","detail":"Tenant not registered in portal"}
```

## Testing

```bash
pytest -q
```

Tests cover:
- Positive isolation for tenant A and B
- Negative cross-tenant read/update/delete
- CRUD lifecycle across core entities
- Integration flow portal-service -> database-service

## Next step: persistence

To move beyond in-memory SQLite, switch to a persistent connection URL and add migrations while preserving tenant predicates in all queries.
