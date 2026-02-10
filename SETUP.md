# Setup & Run

## Prerequisites
- Python 3.11+
- pip / venv
- Node runtime only if running Reflex frontend dev server

## Install

```bash
python -m venv .venv
source .venv/bin/activate
pip install -e '.[dev]'
```

## Run database-service

```bash
uvicorn services.database_service.app:app --host 0.0.0.0 --port 8001 --reload
```

## Run portal-service API

```bash
uvicorn services.portal_service.app:app.api --host 0.0.0.0 --port 8000 --reload
```

## Run Reflex frontend

```bash
reflex run --frontend-only --frontend-port 3000
```

Open: `http://127.0.0.1:3000`

## Test suite

```bash
pytest
```

## Manual multi-tenant checks

```bash
# create two tenants
TENANT_A=$(curl -s -X POST http://127.0.0.1:8000/api/tenants -H 'content-type: application/json' -d '{"name":"A"}' | python -c 'import sys, json; print(json.load(sys.stdin)["data"]["id"])')
TENANT_B=$(curl -s -X POST http://127.0.0.1:8000/api/tenants -H 'content-type: application/json' -d '{"name":"B"}' | python -c 'import sys, json; print(json.load(sys.stdin)["data"]["id"])')

# A creates one product
curl -s -X POST http://127.0.0.1:8000/api/products -H "X-Tenant-ID: ${TENANT_A}" -H 'content-type: application/json' -d '{"data":{"name":"A-only","price":1}}'

# A sees 1 product, B sees 0
curl -s http://127.0.0.1:8000/api/products -H "X-Tenant-ID: ${TENANT_A}"
curl -s http://127.0.0.1:8000/api/products -H "X-Tenant-ID: ${TENANT_B}"
```
