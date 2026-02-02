from typing import List
from .db import get_cursor


def list_views() -> List[str]:
    with get_cursor() as cur:
        cur.execute("SELECT TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS")
        return [row[0] for row in cur.fetchall()]


def list_procedures() -> List[str]:
    with get_cursor() as cur:
        cur.execute("SELECT ROUTINE_NAME FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE='PROCEDURE'")
        return [row[0] for row in cur.fetchall()]


def exec_procedure(name: str, params: dict):
    placeholders = ','.join('?' for _ in params)
    query = f"EXEC {name} {placeholders}" if placeholders else f"EXEC {name}"
    values = list(params.values())
    with get_cursor() as cur:
        cur.execute(query, *values)
        try:
            columns = [d[0] for d in cur.description] if cur.description else []
            rows = [dict(zip(columns, row)) for row in cur.fetchall()] if columns else []
            return rows
        finally:
            cur.commit()


def fetch_view(view_name: str):
    with get_cursor() as cur:
        cur.execute(f"SELECT * FROM {view_name}")
        columns = [d[0] for d in cur.description]
        return [dict(zip(columns, row)) for row in cur.fetchall()]
