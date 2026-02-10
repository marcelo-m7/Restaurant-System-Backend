# Setup Guide

## 1) Prerequisites

- Python **3.11+**
- `pip`
- Optional: `pyenv` for version pinning

## 2) Environment setup

```bash
pyenv local 3.11.14  # optional
python -m venv .venv
source .venv/bin/activate
pip install -e '.[dev]'
```

## 3) Environment variables

Copy and edit from `.env.example`:

```bash
cp .env.example .env
```

Key variables:

- `PORTAL_DATABASE_SERVICE_URL`: where portal calls database-service.
- `DATABASE_URL`: configured as SQLite in-memory by default for local dev notes.
- `PORTAL_PORT`, `DATABASE_PORT`: runtime ports.

## 4) Run services locally

```bash
# terminal A
uvicorn services.database_service.app:app --host 0.0.0.0 --port 8001

# terminal B
uvicorn services.portal_service.app:app --host 0.0.0.0 --port 8000
```

## 5) Verify basic behavior

```bash
curl -s http://127.0.0.1:8001/health
curl -s http://127.0.0.1:8000/
```

## 6) Database notes (SQLite in-memory)

- Database-service uses isolated in-memory SQLite per process using `StaticPool`.
- Test runs are deterministic because each app instance starts from a fresh schema.
- Data is ephemeral and resets when process exits.

## 7) Troubleshooting

- **`MISSING_TENANT`**: include `X-Tenant-ID` header.
- **`INVALID_REFERENCE`**: you referenced an ID from another tenant scope.
- **`UNKNOWN_ENTITY`**: entity path is not in supported set.
- **Port in use**: switch `--port` or stop prior process.
