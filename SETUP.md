# Setup Guide

## 1) Create virtual environment

```bash
python -m venv .venv
source .venv/bin/activate
pip install -e .[dev]
```

## 2) Configure environment

Copy defaults:

```bash
cp .env.example .env
```

Key variables:
- `DATABASE_SERVICE_URL`: portal upstream base URL.
- `PORTAL_HOST`, `PORTAL_PORT`: portal bind settings.
- `DATABASE_HOST`, `DATABASE_PORT`: database-service bind settings.
- `DATABASE_URL`: reserved for persistence migrations (current service uses in-memory SQLite).

## 3) Start services

Terminal A:

```bash
uvicorn services.database_service.main:app --host 0.0.0.0 --port 8001 --reload
```

Terminal B:

```bash
DATABASE_SERVICE_URL=http://127.0.0.1:8001 \
uvicorn services.portal_service.main:api --host 0.0.0.0 --port 8000 --reload
```

Optional Reflex page shell:

```bash
reflex run
```

## SQLite in-memory/shared notes

- The database-service uses a process-local in-memory SQLite connection.
- Data resets whenever the service process restarts.
- Great for tests/dev speed, not suitable for durable environments.
- Multi-process deployments need a persistent DB and migration strategy.

## 4) Verify setup

```bash
curl -s http://127.0.0.1:8001/health
curl -s http://127.0.0.1:8000/health
```

## 5) Run QA checks

```bash
pytest -q
ruff check .
ruff format .
mypy .
pytest --cov=services --cov=tests --cov-report=term-missing
```

## Troubleshooting

- **`missing_tenant` errors**: include `X-Tenant-ID` header.
- **`unknown_tenant` from portal**: create tenant via `POST /tenants` first.
- **Reflex warnings on Python 3.10**: upgrade to Python 3.11+ for best support.
- **Empty data after restart**: expected with in-memory SQLite.
