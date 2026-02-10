# Restaurant System Backend - Multi-tenant Foundation

This repository now serves as the **architecture and implementation foundation** for a two-microservice platform:

1. **Portal Service (Reflex/Python)**
   - Tenant onboarding
   - User and access bootstrap
   - Database connection registration and validation
2. **Database Service (Python + SQLite in-memory for now)**
   - Multi-tenant data API
   - Tenant-scoped persistence and domain flows

> Current status: this repository is still documentation-heavy and does not yet contain the full service source code. The goal of this baseline is to make implementation decisions explicit and reduce ambiguity before code expansion.

## Why this cleanup was necessary

The previous repository context mixed references to React + SQL Server artifacts and restaurant POS domain drafts. That created architectural drift relative to the current target (Reflex Portal + tenant-aware Database service). The updated docs establish:

- Clear service boundaries
- Tenant lifecycle and ownership
- Database connection strategy
- Domain model and flow contracts
- A recommended scalable directory layout

## Repository structure (target)

```text
.
├─ services/
│  ├─ portal/                     # Reflex app (tenant onboarding + admin UI)
│  │  ├─ app/
│  │  │  ├─ ui/                   # Reflex pages/components/state
│  │  │  ├─ domain/               # Portal use-cases + entities
│  │  │  ├─ infrastructure/       # Adapters: HTTP clients, auth providers
│  │  │  └─ config/
│  │  ├─ tests/
│  │  └─ pyproject.toml
│  └─ database/
│     ├─ app/
│     │  ├─ api/                  # REST/HTTP handlers
│     │  ├─ domain/               # Core entities + business rules
│     │  ├─ persistence/          # Repositories + DB adapters
│     │  ├─ infrastructure/       # Logging, telemetry, integration adapters
│     │  └─ config/
│     ├─ migrations/
│     ├─ tests/
│     └─ pyproject.toml
├─ docs/
│  ├─ decisions/                  # ADRs
│  ├─ diagrams/
│  └─ legacy/                     # Legacy exploratory docs kept for traceability
├─ README.md
├─ ARCHITECTURE.md
├─ SETUP.md
└─ .env.example
```

## Core documentation

- [ARCHITECTURE.md](./ARCHITECTURE.md) - service boundaries, lifecycle, flows, risks, and technical debt.
- [SETUP.md](./SETUP.md) - local setup and execution strategy for the future implementation.

## Legacy artifacts

Earlier exploratory domain notes were preserved under `docs/` and should be considered **draft references only** until migrated into the new service-specific implementation docs.

## Next implementation milestones

1. Scaffold `services/portal` Reflex app with health endpoint and onboarding screen.
2. Scaffold `services/database` API with tenant-aware middleware and in-memory SQLite adapter.
3. Add contract tests between Portal and Database service for tenant registration.
4. Introduce ADRs for tenancy model and migration path to persistent storage.
