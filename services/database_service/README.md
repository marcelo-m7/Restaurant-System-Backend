# database_service

`database_service` is the tenant-aware persistence API for the Restaurant System baseline.

## Responsibilities

- Own CRUD persistence for domain entities.
- Require `X-Tenant-ID` for all entity operations.
- Enforce tenant scoping with `tenant_id` in every query.
- Expose `GET /health` for local health checks.

## Run locally

```bash
uvicorn services.database_service.main:app --host 0.0.0.0 --port 8001 --reload
```
