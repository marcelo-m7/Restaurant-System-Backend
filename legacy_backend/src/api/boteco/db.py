import os
import pyodbc
from contextlib import contextmanager


def get_connection_string() -> str:
    dsn = os.getenv('BOTECOPRO_DB_DSN')
    if not dsn:
        raise RuntimeError('BOTECOPRO_DB_DSN environment variable not set')
    return dsn


def connect():
    return pyodbc.connect(get_connection_string())


@contextmanager
def get_cursor():
    conn = connect()
    try:
        cursor = conn.cursor()
        yield cursor
    finally:
        cursor.close()
        conn.close()
