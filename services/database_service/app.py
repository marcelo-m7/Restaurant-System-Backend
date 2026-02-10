from __future__ import annotations

from datetime import datetime, timezone
from typing import Any

from fastapi import Depends, FastAPI, Header, HTTPException, status
from sqlalchemy import create_engine, select
from sqlalchemy.orm import Session, sessionmaker

from services.database_service.models import Base, ENTITY_MODELS, serialize_model
from services.database_service.schemas import APIError, EntityListResponse, EntityPayload, EntityResponse


def create_db_app() -> FastAPI:
    app = FastAPI(title="database-service", version="0.1.0")

    engine = create_engine(
        "sqlite:///file:restaurant_tenant_db?mode=memory&cache=shared",
        connect_args={"check_same_thread": False, "uri": True},
        future=True,
    )
    Base.metadata.create_all(engine)
    session_factory = sessionmaker(bind=engine, class_=Session, expire_on_commit=False)

    def get_session() -> Session:
        with session_factory() as session:
            yield session

    def require_tenant(x_tenant_id: str | None = Header(default=None)) -> str:
        if not x_tenant_id:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=APIError(
                    error="MISSING_TENANT",
                    message="X-Tenant-ID header is required.",
                    timestamp=datetime.now(timezone.utc),
                ).model_dump(mode="json"),
            )
        return x_tenant_id

    def get_model(entity: str):
        model = ENTITY_MODELS.get(entity)
        if not model:
            raise HTTPException(status_code=404, detail=f"Unknown entity: {entity}")
        return model

    @app.get("/health")
    def health() -> dict[str, str]:
        return {"status": "ok"}

    @app.post("/v1/{entity}", response_model=EntityResponse)
    def create_entity(
        entity: str,
        payload: EntityPayload,
        tenant_id: str = Depends(require_tenant),
        session: Session = Depends(get_session),
    ) -> EntityResponse:
        model = get_model(entity)
        item = model(**payload.data, tenant_id=tenant_id)
        session.add(item)
        session.commit()
        session.refresh(item)
        return EntityResponse(data=serialize_model(item))

    @app.get("/v1/{entity}", response_model=EntityListResponse)
    def list_entities(
        entity: str,
        tenant_id: str = Depends(require_tenant),
        session: Session = Depends(get_session),
    ) -> EntityListResponse:
        model = get_model(entity)
        rows = session.scalars(select(model).where(model.tenant_id == tenant_id)).all()
        return EntityListResponse(items=[serialize_model(row) for row in rows])

    @app.get("/v1/{entity}/{item_id}", response_model=EntityResponse)
    def get_entity(
        entity: str,
        item_id: str,
        tenant_id: str = Depends(require_tenant),
        session: Session = Depends(get_session),
    ) -> EntityResponse:
        model = get_model(entity)
        row = session.scalar(select(model).where(model.id == item_id, model.tenant_id == tenant_id))
        if not row:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=APIError(
                    error="TENANT_SCOPE_VIOLATION",
                    message="Record not found for tenant scope.",
                    timestamp=datetime.now(timezone.utc),
                ).model_dump(mode="json"),
            )
        return EntityResponse(data=serialize_model(row))

    @app.put("/v1/{entity}/{item_id}", response_model=EntityResponse)
    def update_entity(
        entity: str,
        item_id: str,
        payload: EntityPayload,
        tenant_id: str = Depends(require_tenant),
        session: Session = Depends(get_session),
    ) -> EntityResponse:
        model = get_model(entity)
        row = session.scalar(select(model).where(model.id == item_id, model.tenant_id == tenant_id))
        if not row:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=APIError(
                    error="TENANT_SCOPE_VIOLATION",
                    message="Update denied outside tenant scope.",
                    timestamp=datetime.now(timezone.utc),
                ).model_dump(mode="json"),
            )
        for key, value in payload.data.items():
            if key in {"id", "tenant_id", "created_at", "updated_at"}:
                continue
            setattr(row, key, value)
        session.commit()
        session.refresh(row)
        return EntityResponse(data=serialize_model(row))

    @app.delete("/v1/{entity}/{item_id}")
    def delete_entity(
        entity: str,
        item_id: str,
        tenant_id: str = Depends(require_tenant),
        session: Session = Depends(get_session),
    ) -> dict[str, Any]:
        model = get_model(entity)
        row = session.scalar(select(model).where(model.id == item_id, model.tenant_id == tenant_id))
        if not row:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=APIError(
                    error="TENANT_SCOPE_VIOLATION",
                    message="Delete denied outside tenant scope.",
                    timestamp=datetime.now(timezone.utc),
                ).model_dump(mode="json"),
            )
        session.delete(row)
        session.commit()
        return {"status": "deleted", "id": item_id}

    return app


app = create_db_app()
