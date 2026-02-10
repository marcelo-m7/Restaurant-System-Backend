# Restaurant System Backend

A two-service, multi-tenant backend for restaurant operations.

- **database-service**: FastAPI + SQLAlchemy CRUD API with tenant isolation.
- **portal-service**: FastAPI portal API that manages tenants and proxies CRUD calls to database-service.

> Tenant scope is enforced with the `X-Tenant-ID` header on all tenant-owned entity endpoints.

## Architecture at a glance

- `services/database_service`: own API + in-memory SQLite schema bootstrap.
- `services/portal_service`: tenant endpoints + proxy to database-service using HTTPX.
- `tests/`: service-level and integration tests.

See [ARCHITECTURE.md](ARCHITECTURE.md) for full flow details.

## Quickstart

```bash
pyenv local 3.11.14  # or any Python 3.11+
python -m venv .venv
source .venv/bin/activate
pip install -e '.[dev]'
```

Run services:

```bash
# terminal 1
uvicorn services.database_service.app:app --host 0.0.0.0 --port 8001

# terminal 2
uvicorn services.portal_service.app:app --host 0.0.0.0 --port 8000
```

Health checks:

```bash
curl -s http://127.0.0.1:8001/health
curl -s http://127.0.0.1:8000/
```

## Multi-tenancy model (`X-Tenant-ID`)

- Required by `database-service` on `/v1/*` routes.
- Required by `portal-service` on proxied `/api/{entity}` routes.
- Data is isolated by row-level `tenant_id` checks for read/write/delete.
- Foreign-key references are validated to prevent cross-tenant linkage.

## Common workflow

```bash
# Create tenant
TENANT_ID=$(curl -s -X POST http://127.0.0.1:8000/api/tenants \
  -H 'content-type: application/json' \
  -d '{"name":"Tenant A"}' | python -c 'import sys,json; print(json.load(sys.stdin)["data"]["id"])')

# Create product for tenant
curl -s -X POST http://127.0.0.1:8000/api/products \
  -H "X-Tenant-ID: ${TENANT_ID}" \
  -H 'content-type: application/json' \
  -d '{"data":{"name":"Espresso","price":3.5}}'

# List products for tenant
curl -s http://127.0.0.1:8000/api/products -H "X-Tenant-ID: ${TENANT_ID}"
```

## Developer quality checks

```bash
ruff check .
mypy .
pytest --cov=services --cov=tests --cov-report=term-missing
```

See [docs/TESTING.md](docs/TESTING.md) for failure interpretation and troubleshooting.
