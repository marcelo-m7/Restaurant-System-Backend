# Restaurant System Backend

A two-microservice, multi-tenant backend for restaurant domain workflows.

## What this system is

This repository contains:
- **database-service** (FastAPI + SQLite in-memory): tenant-scoped CRUD and restaurant workflow endpoints.
- **portal-service** (FastAPI proxy + Reflex pages): tenant registry and `/api/*` proxy to database-service.

## Architecture summary

```text
Client -> portal-service (/api/* + /tenants) -> database-service
                                       |
                                       +-> forwards X-Tenant-ID
```

Each database row stores `tenant_id`. All domain queries are filtered by tenant.

## Quickstart

```bash
python -m venv .venv
source .venv/bin/activate
pip install -e .[dev]
```

Run database-service:

```bash
uvicorn services.database_service.main:app --host 0.0.0.0 --port 8001 --reload
```

Run portal-service:

```bash
DATABASE_SERVICE_URL=http://127.0.0.1:8001 \
uvicorn services.portal_service.main:api --host 0.0.0.0 --port 8000 --reload
```

Run tests and quality checks:

```bash
pytest -q
ruff check .
ruff format .
mypy .
pytest --cov=services --cov=tests --cov-report=term-missing
```

## Multi-tenancy (`X-Tenant-ID`)

- Required for all domain endpoints (`/categories`, `/orders`, `/payments`, etc.).
- Tenant must be registered in portal first for proxied calls.
- Missing header returns `400`.
- Unknown tenant in portal returns `403`.
- Cross-tenant access returns `404` on database-service resources.

## Common workflow example

```bash
# 1) Register tenant in portal
curl -sX POST http://127.0.0.1:8000/tenants \
  -H 'content-type: application/json' \
  -d '{"name":"Demo Tenant"}'

# 2) Use tenant header for all /api calls
curl -sX POST http://127.0.0.1:8000/api/categories \
  -H 'content-type: application/json' \
  -H 'X-Tenant-ID: <tenant_id>' \
  -d '{"name":"Main"}'

# 3) Health checks
curl -s http://127.0.0.1:8000/health
curl -s http://127.0.0.1:8001/health
```

## Additional docs

- [SETUP.md](SETUP.md)
- [ARCHITECTURE.md](ARCHITECTURE.md)
- [docs/API.md](docs/API.md)
- [docs/TESTING.md](docs/TESTING.md)
- [docs/audit_evidence/](docs/audit_evidence/)
