# Restaurant System Backend (Baseline v0.1)

Minimal two-microservice baseline with strict multi-tenant isolation:

- **portal-service**: Reflex app + tenant management + proxy API.
- **database-service**: FastAPI + SQLite (in-memory shared cache) + tenant-scoped CRUD.

## Why `X-Tenant-ID` header?

This baseline uses `X-Tenant-ID` for tenant propagation because it is explicit, easy to trace in logs, and portable across UI/API requests without path coupling. Every tenant-owned CRUD operation requires this header.

## Project structure

```text
services/
  database_service/
    app.py
    models.py
    schemas.py
  portal_service/
    app.py
    client.py
tests/
  test_database_service.py
  test_portal_integration.py
ARCHITECTURE.md
SETUP.md
pyproject.toml
```

## Quick start

```bash
python -m venv .venv
source .venv/bin/activate
pip install -e '.[dev]'
```

Start services in two terminals:

```bash
# Terminal A
uvicorn services.database_service.app:app --host 0.0.0.0 --port 8001

# Terminal B (portal API + Reflex frontend backend)
uvicorn services.portal_service.app:app.api --host 0.0.0.0 --port 8000
```

Optional Reflex frontend dev server:

```bash
reflex run --frontend-only --frontend-port 3000
```

## cURL flow

1. Create a tenant in portal service:

```bash
curl -s -X POST http://127.0.0.1:8000/api/tenants \
  -H 'content-type: application/json' \
  -d '{"name":"tenant-a"}'
```

2. Use tenant id to create product through portal proxy:

```bash
curl -s -X POST http://127.0.0.1:8000/api/products \
  -H 'X-Tenant-ID: <tenant-id>' \
  -H 'content-type: application/json' \
  -d '{"data":{"name":"Latte","price":5.5}}'
```

3. List products for same tenant:

```bash
curl -s http://127.0.0.1:8000/api/products -H 'X-Tenant-ID: <tenant-id>'
```

4. Cross-tenant access is blocked (404 scope violation):

```bash
curl -i http://127.0.0.1:8000/api/products/<product-id> -H 'X-Tenant-ID: another-tenant'
```

## Tests

```bash
pytest
```

Coverage includes:

- tenant isolation A vs B
- cross-tenant read denial
- CRUD lifecycle across core entities
- portal -> database tenant-context forwarding

## Next step for persistence

Swap in-memory SQLite with persistent DB by changing SQLAlchemy URL and introducing migrations (Alembic). Existing repository/API contracts keep tenant checks independent of engine choice.
