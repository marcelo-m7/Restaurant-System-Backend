# portal_service

`portal_service` is the tenant-facing API gateway for the Restaurant System.

## Responsibilities

- Register and list tenants (`/tenants` endpoints).
- Validate `X-Tenant-ID` on tenant-scoped API requests.
- Proxy all tenant API requests from `/api/*` to `database_service`, including domain workflow endpoints.
- Expose `GET /health` for local health checks.
- Serve a Reflex UI with simple management pages for units, areas, tables, products, orders, payments, and tabs.

## Run locally

```bash
DATABASE_SERVICE_URL=http://127.0.0.1:8001 \
uvicorn services.portal_service.main:api --host 0.0.0.0 --port 8000 --reload
```

Optional Reflex UI development server:

```bash
reflex run
```
