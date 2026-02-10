# Architecture

## Services and responsibilities

## 1) `database-service`
- Owns domain persistence and business workflows.
- Exposes tenant-scoped generic CRUD for entities:
  - `categories`, `products`, `units`, `areas`, `users`, `tables`, `tabs`
- Exposes domain endpoints:
  - `POST /tabs/open`
  - `POST /orders`
  - `POST /order-items`
  - `POST /orders/{id}/send`
  - `POST /order-items/{id}/void`
  - `POST /tabs/{id}/recalculate`
  - `POST /payments`
  - `POST /payments/{id}/confirm`
  - `POST /tabs/{id}/close`

## 2) `portal-service`
- Stores tenant registry in-memory.
- Rejects unknown tenants before forwarding.
- Proxies `/api/{path}` to database-service using HTTPX.
- Preserves tenant isolation by forwarding `X-Tenant-ID`.

## Request flow

1. Client registers tenant through portal (`POST /tenants`).
2. Client calls portal `/api/*` with `X-Tenant-ID`.
3. Portal validates tenant exists locally.
4. Portal forwards request to database-service with same header.
5. Database-service validates tenant header and scopes all DB queries.

## Data model overview

Main tables include:
- `categories`, `products`
- `units`, `areas`, `dining_tables`
- `tabs`, `orders`, `order_items`, `payments`

Every table includes `tenant_id` to enforce shared-database multi-tenancy.

## Key design decisions and tradeoffs

- **In-memory SQLite**: simple and fast for test/dev; non-durable and single-process.
- **Tenant header based isolation**: explicit and easy to test; clients must always send header.
- **Portal registry in memory**: low complexity; registry resets on restart.
- **Generic CRUD + domain routes**: broad API surface quickly, but route collisions must be handled carefully.

## Error model

App-level errors follow:

```json
{"error": "string_code", "detail": "message"}
```

Validation errors from FastAPI/Pydantic are returned as standard `422` responses.
