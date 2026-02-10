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

- **portal-service**: tenant registry + tenant-aware `/api/*` proxy + Reflex management pages.
- **database-service**: tenant-scoped CRUD + domain workflow endpoints.

## Domain APIs (database-service)

- CRUD: `/categories`, `/products`, `/units`, `/areas`, `/users`, `/tables`, `/tabs`.
- Flows:
  - `POST /tabs/open`
  - `POST /orders`
  - `POST /order-items`
  - `POST /orders/{order_id}/send`
  - `POST /order-items/{item_id}/void`
  - `POST /tabs/{tab_id}/recalculate`
  - `POST /payments`
  - `POST /payments/{payment_id}/confirm`
  - `POST /tabs/{tab_id}/close`

## Run locally

```bash
python -m venv .venv
source .venv/bin/activate
pip install -e .[dev]
```

```bash
uvicorn services.database_service.main:app --host 0.0.0.0 --port 8001 --reload
```

```bash
DATABASE_SERVICE_URL=http://127.0.0.1:8001 \
uvicorn services.portal_service.main:api --host 0.0.0.0 --port 8000 --reload
```

Optional Reflex UI:

```bash
reflex run
```

## Tests

```bash
pytest -q
```
