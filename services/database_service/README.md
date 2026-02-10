# database_service

`database_service` is the tenant-aware persistence API for the Restaurant System.

## Responsibilities

- Own CRUD persistence for reference entities (`categories`, `products`, `units`, `areas`, `users`, `tables`, `tabs`).
- Enforce tenant scoping with `tenant_id` in every query.
- Implement domain workflows:
  - `POST /tabs/open`
  - `POST /orders`
  - `POST /order-items`
  - `POST /orders/{order_id}/send`
  - `POST /order-items/{item_id}/void`
  - `POST /tabs/{tab_id}/recalculate`
  - `POST /payments`
  - `POST /payments/{payment_id}/confirm`
  - `POST /tabs/{tab_id}/close`
- Expose `GET /health` for local health checks.

## Run locally

```bash
uvicorn services.database_service.main:app --host 0.0.0.0 --port 8001 --reload
```
