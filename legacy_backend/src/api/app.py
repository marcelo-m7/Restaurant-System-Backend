from fastapi import FastAPI, HTTPException
from typing import Any, Dict
from dotenv import load_dotenv
from boteco import utils

load_dotenv()

app = FastAPI(title="Boteco Pro API")


@app.on_event("startup")
def startup() -> None:
    _register_view_routes()


def _register_view_routes() -> None:
    views = []
    try:
        views = utils.list_views()
    except Exception:
        # Database might not be available on startup
        return
    for view in views:
        route = '/' + view.replace('view_', '').replace('_', '/')

        async def handler(v=view):
            try:
                return utils.fetch_view(v)
            except Exception as e:
                raise HTTPException(status_code=500, detail=str(e))

        app.get(route, name=view)(handler)


@app.post('/exec/{procedure_name}')
async def execute_procedure(procedure_name: str, body: Dict[str, Any] | None = None):
    body = body or {}
    try:
        return utils.exec_procedure(procedure_name, body)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get('/')
def index():
    try:
        views = utils.list_views()
        procs = utils.list_procedures()
    except Exception:
        views = []
        procs = []
    return {'views': views, 'procedures': procs}
