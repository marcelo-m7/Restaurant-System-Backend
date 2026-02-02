import os
from pathlib import Path
import pyodbc
import argparse

SQL_DIR = Path(__file__).resolve().parent / 'sql'


def get_connection_string() -> str:
    dsn = os.getenv('BOTECOPRO_DB_DSN')
    if not dsn:
        raise RuntimeError('BOTECOPRO_DB_DSN environment variable not set')
    return dsn


def connect():
    return pyodbc.connect(get_connection_string(), autocommit=True)


def execute_sql_file(cursor: pyodbc.Cursor, path: Path) -> None:
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


def run_all_scripts(sql_dir: Path = SQL_DIR) -> None:
    files = sorted(sql_dir.glob('*.sql'))
    if not files:
        print(f'No SQL files found in {sql_dir}')
        return
    with connect() as conn:
        cursor = conn.cursor()
        for file in files:
            print(f'Executing {file.name}...')
            execute_sql_file(cursor, file)
        print('All scripts executed successfully.')


def test_connection() -> None:
    try:
        with connect() as conn:
            cur = conn.cursor()
            cur.execute('SELECT @@VERSION')
            version = cur.fetchone()[0]
            print('Connection successful!')
            print(version)
    except Exception as e:
        print('Connection failed:')
        print(e)


def main() -> None:
    parser = argparse.ArgumentParser(description='Boteco Pro DB utility')
    sub = parser.add_subparsers(dest='command', required=True)

    sub.add_parser('test', help='Test connection to the database')
    sub.add_parser('run', help='Execute all SQL scripts in sequence')

    args = parser.parse_args()

    if args.command == 'test':
        test_connection()
    elif args.command == 'run':
        run_all_scripts()


if __name__ == '__main__':
    main()
