import os
import sys
from pathlib import Path
import pytest

# Ensure db package is in path
sys.path.append(str(Path(__file__).resolve().parents[1]))
import db.service as service


def test_connection():
    dsn = os.getenv('BOTECOPRO_DB_DSN')
    if not dsn:
        pytest.skip('BOTECOPRO_DB_DSN not configured')
    with service.connect() as conn:
        cur = conn.cursor()
        cur.execute('SELECT 1')
        assert cur.fetchone()[0] == 1

