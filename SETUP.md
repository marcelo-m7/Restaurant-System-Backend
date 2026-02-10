# Setup Guide

## Prerequisites

- Python 3.11+
- `pip` (or `uv`) and virtual environment support
- Optional: Docker and Docker Compose for future infra workflows

## Installation

```bash
python -m venv .venv
source .venv/bin/activate
pip install -e .[dev]
```

## Environment Configuration

Copy environment defaults:

```bash
cp .env.example .env
```

Set values as needed for local development.

## Required Environment Variables

- `DATABASE_SERVICE_URL`: portal-service upstream URL for database-service.
- `PORTAL_HOST`: host interface for portal-service.
- `PORTAL_PORT`: port for portal-service API.
- `DATABASE_HOST`: host interface for database-service.
- `DATABASE_PORT`: port for database-service API.
- `DATABASE_URL`: persistence DSN (currently defaults to in-memory SQLite).

## Recommended Local Run Model

Start each service in a separate terminal.

### 1) database-service

```bash
uvicorn services.database_service.main:app --host 0.0.0.0 --port 8001 --reload
```

### 2) portal-service API

```bash
DATABASE_SERVICE_URL=http://127.0.0.1:8001 \
uvicorn services.portal_service.main:api --host 0.0.0.0 --port 8000 --reload
```

### 3) Optional Reflex UI

```bash
reflex run
```

## Health Checks

- `GET http://127.0.0.1:8000/health` (portal-service)
- `GET http://127.0.0.1:8001/health` (database-service)

## Test Suite

```bash
pytest -q
```
