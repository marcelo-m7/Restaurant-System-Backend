# Architecture

## Overview

This repository implements a **two-service baseline** for a multi-tenant restaurant system:

1. **portal-service** (`services/portal_service`): tenant registry + tenant-aware API proxy + Reflex UI shell.
2. **database-service** (`services/database_service`): domain CRUD API with tenant filtering on every query.

The architecture follows a **shared-database multi-tenant model**: every persisted table includes a `tenant_id` column and every CRUD query is constrained by that tenant.

## Service Boundaries

### portal-service

- Registers tenants (`POST /tenants`).
- Stores known tenants in the in-memory registry.
- Requires `X-Tenant-ID` for proxied domain requests under `/api/*`.
- Rejects unknown tenants before forwarding to database-service.
- Proxies domain CRUD requests to database-service.
- Exposes `GET /health`.

### database-service

- Owns all domain entity persistence.
- Requires `X-Tenant-ID` for domain CRUD endpoints.
- Applies `tenant_id` filter in create/read/update/delete flows.
- Returns `404 resource_not_found` for cross-tenant resource access.
- Exposes `GET /health`.

## Tenant Propagation Convention

- Header name: `X-Tenant-ID`.
- Required for all domain CRUD operations.
- Not required for portal tenant registration endpoints.

## Entity Surface

The API currently exposes tenant-scoped CRUD for:

- `categories`
- `products`
- `tables`
- `tabs`
- `orders`
- `order-items`
- `payments`

Generic CRUD route pattern:

- `POST /{entity}`
- `GET /{entity}`
- `GET /{entity}/{id}`
- `PUT /{entity}/{id}`
- `DELETE /{entity}/{id}`

Portal-service exposes the same domain routes through `/api/*`.

## Health Contract

Both services must expose:

- `GET /health`

Current response contract:

```json
{
  "status": "ok"
}
```

## Error Contract

Application errors are returned as:

```json
{
  "error": "string_code",
  "detail": "human_readable_message"
}
```

### Common Error Codes

- `missing_tenant`: `X-Tenant-ID` was not provided.
- `unknown_tenant`: tenant is not registered in portal-service.
- `tenant_not_found`: requested tenant record does not exist.
- `entity_not_found`: unsupported entity route was requested.
- `resource_not_found`: entity record not found for the current tenant.

Typical status codes:

- `400` for malformed/missing tenant headers.
- `403` when a tenant is unknown to portal-service.
- `404` for missing entities/resources.
- `422` for schema validation errors.
