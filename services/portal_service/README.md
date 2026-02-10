# portal_service

`portal_service` is the tenant-facing API gateway for the Restaurant System baseline.

## Responsibilities

- Register and list tenants (`/tenants` endpoints).
- Validate `X-Tenant-ID` on tenant-scoped API requests.
- Proxy CRUD requests from `/api/*` to `database_service`.
- Expose `GET /health` for local health checks.
- Serve the Reflex application shell.

## Run locally

```bash
DATABASE_SERVICE_URL=http://127.0.0.1:8001 \
uvicorn services.portal_service.main:api --host 0.0.0.0 --port 8000 --reload
```

Optional Reflex UI development server:

```bash
reflex run
```
