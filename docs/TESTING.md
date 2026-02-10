# Testing and QA

## Run all tests

```bash
pytest -q
```

## Coverage

```bash
pytest --cov=services --cov=tests --cov-report=term-missing
```

## Linting and formatting

```bash
ruff check .
ruff format .
```

## Type checking

```bash
mypy .
```

## Pre-commit (optional)

```bash
pre-commit install
pre-commit run --all-files
```

## Interpreting failures

- `404` on domain endpoints can indicate tenant isolation or invalid references.
- `409` indicates state transition/business rule conflicts (e.g., sending empty order).
- `422` indicates schema validation errors.
- Portal `403 unknown_tenant` means tenant was not registered via `/tenants`.

## Audit evidence

Artifacts from this audit are stored under `docs/audit_evidence/`.
