# Testing & Quality Checks

## Run all tests

```bash
pytest
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

- `MISSING_TENANT`: test request forgot `X-Tenant-ID`.
- `UNKNOWN_ENTITY`: typo in entity path.
- Coverage gaps under `services/portal_service/app.py`: add proxy edge-case tests.
- Type errors around framework attributes: prefer explicit wrappers/casts at boundaries.
