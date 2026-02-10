# Restaurant System Backend

Multi-tenant runnable baseline with a **portal-service** and a **database-service**.

## Repository structure

```text
.
├── services/
│   ├── portal_service/
│   └── database_service/
├── docs/
├── tests/
├── ARCHITECTURE.md
├── DOMAIN.md
├── SETUP.md
└── README.md
```

## Services

- **portal-service**: tenant registry + tenant-aware `/api/*` proxy + Reflex app shell.
- **database-service**: tenant-scoped CRUD API for domain entities.

## Environment variables

Create a `.env` from `.env.example` and adjust values:

- `DATABASE_SERVICE_URL`: URL used by portal-service to reach database-service.
- `PORTAL_HOST`, `PORTAL_PORT`: portal-service bind host and port.
- `DATABASE_HOST`, `DATABASE_PORT`: database-service bind host and port.
- `DATABASE_URL`: storage DSN (in-memory SQLite by default).

## Run locally

Install dependencies:

```bash
python -m venv .venv
source .venv/bin/activate
pip install -e .[dev]
```

Start database-service:

```bash
uvicorn services.database_service.main:app --host 0.0.0.0 --port 8001 --reload
```

Start portal-service API:

```bash
DATABASE_SERVICE_URL=http://127.0.0.1:8001 \
uvicorn services.portal_service.main:api --host 0.0.0.0 --port 8000 --reload
```

Optional Reflex UI:

```bash
reflex run
```

## Quickstart (tenant + CRUD + isolation)

1) Create a tenant through portal-service:

```bash
curl -s -X POST http://127.0.0.1:8000/tenants \
  -H 'content-type: application/json' \
  -d '{"name":"Tenant A"}'
```

2) Use the returned `tenant_id` in proxy CRUD requests:

```bash
TENANT_ID="<tenant-id>"

curl -s -X POST http://127.0.0.1:8000/api/categories \
  -H "X-Tenant-ID: ${TENANT_ID}" \
  -H 'content-type: application/json' \
  -d '{"name":"Burgers"}'

curl -s http://127.0.0.1:8000/api/categories \
  -H "X-Tenant-ID: ${TENANT_ID}"
```

3) Demonstrate cross-tenant isolation:

```bash
curl -s http://127.0.0.1:8000/api/categories/1 \
  -H "X-Tenant-ID: some-other-tenant"
```

Expected error:

```json
{"error":"unknown_tenant","detail":"Tenant not registered in portal"}
```

## Health endpoints

- `GET /health` on portal-service
- `GET /health` on database-service

Both currently return:

```json
{"status":"ok"}
```

## Error contract

Application-level errors follow:

```json
{
  "error": "string_code",
  "detail": "human_readable_message"
}
```

See `ARCHITECTURE.md` for common codes and expected status mapping.

## Tests

Run all tests:

```bash
pytest -q
```
