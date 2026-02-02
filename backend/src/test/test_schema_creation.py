import os
from pathlib import Path
import pytest
import pyodbc

SQL_DIR = Path(__file__).resolve().parents[1] / 'db' / 'sql'

# Helper to execute scripts separated by GO
def run_sql_script(cursor, path):
    with open(path, 'r', encoding='utf-8') as f:
        contents = f.read()
    for statement in contents.split('\nGO'):
        stmt = statement.strip()
        if stmt:
            cursor.execute(stmt)
            try:
                cursor.commit()
            except Exception:
                pass

def get_connection():
    dsn = os.getenv('BOTECOPRO_DB_DSN')
    if not dsn:
        return None
    return pyodbc.connect(dsn, autocommit=True)

@pytest.fixture(scope='session')
def conn():
    connection = get_connection()
    if connection is None:
        pytest.skip('BOTECOPRO_DB_DSN not configured')
    yield connection
    connection.close()

def test_create_tables(conn):
    cur = conn.cursor()
    run_sql_script(cur, SQL_DIR / '01_create_tables.sql')
    cur.execute("SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='Prato'")
    assert cur.fetchone()[0] == 1


