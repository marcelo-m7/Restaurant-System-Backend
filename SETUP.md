# SETUP

This document defines the recommended development setup for the two-service architecture.

> Note: service code scaffolds are expected to be added under `services/` as the next milestone.

## 1. Prerequisites

- Python 3.11+
- `uv` or `pip` + virtualenv
- Docker + Docker Compose (optional for future infra dependencies)
- Make (optional)

## 2. Environment variables

Create a `.env` file from `.env.example`:

```bash
cp .env.example .env
```

Then fill required values.

## 3. Recommended local run model

### Portal Service

- Runtime: Reflex
- Port: `3000` (or Reflex default in your setup)
- Depends on: Database Service base URL and service token

### Database Service

- Runtime: Python API server (FastAPI/Flask-compatible architecture)
- Port: `8000`
- Initial persistence: in-memory SQLite (`sqlite:///:memory:`)

## 4. Suggested boot sequence

1. Start Database Service.
2. Run migrations/bootstrap hooks (if enabled).
3. Start Portal Service.
4. Open Portal and execute tenant registration flow.

## 5. Health checks (expected endpoints)

- Database Service: `GET /health`
- Portal Service: `GET /health`

Both should return service identity + environment + dependency status.

## 6. Development checks

Once code is scaffolded, standardize the following checks:

```bash
# Lint
ruff check .

# Format
ruff format .

# Type check
pyright

# Tests
pytest
```

## 7. Troubleshooting baseline

- If tenant provisioning fails, inspect correlation IDs in both service logs.
- If connection validation fails, verify host/port secrets in Portal config payload.
- If tenant data leaks across requests, audit tenant middleware and repository filters.

## 8. Migration guidance (SQLite -> persistent DB)

When moving off in-memory SQLite:

1. Switch to file-backed SQLite in development.
2. Introduce migration tooling and schema versioning.
3. Validate tenant-specific unique constraints.
4. Add data retention and backup strategy before production DB adoption.
