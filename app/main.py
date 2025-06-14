import os
import json
import subprocess
from datetime import datetime
from fastapi import FastAPI, Query, HTTPException
from typing import Annotated
from .routers import assets

app = FastAPI()

from fastapi.middleware.cors import CORSMiddleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # or specify ["http://localhost:8000"] for stricter config
    allow_credentials=True,
    allow_methods=["*"],  # or specify ["POST", "GET"]
    allow_headers=["*"],
)

app.include_router(
        assets.router,
        prefix="/sysinfo"
)

@app.get("/sysinfo")
def test_params():
    return []

@app.get("/sysinfo/assets/{asset_id}/ironiq_well_names")
def read_assets(asset_id: str):
    '''Get details of an asset type'''

    p1 = subprocess.run(['bash', os.path.join(os.getenv("SCRIPTS_DIR"), "searchWell.sh"), "dba_access", "novadb", asset_id], capture_output=True)

    response = {}

    if p1.returncode > 0:
        with open(os.path.join(os.getenv('DATA_DIR'), 'assets', 'map', "error_lines.txt"), "w") as f:
            f.write(p1.stderr.decode('utf8'))

        p2 = subprocess.run(['grep', 'ERROR', os.path.join(os.getenv('DATA_DIR'), 'assets','map',  "error_lines.txt")], capture_output=True)

        subprocess.run(['rm', os.path.join(os.getenv('DATA_DIR'), 'assets', 'map', "error_lines.txt")], capture_output=True)

        error_lines = p2.stdout.decode('utf8').split('\n')

        response['error'] = error_lines[0].replace('ERROR:', '').strip()
    else:
        with open(os.path.join(os.getenv('DATA_DIR'), 'assets', 'map', "success_lines.txt"), "w") as f:
            f.write(p1.stdout.decode('utf8'))

        p2 = subprocess.run(['bash', os.path.join(os.getenv('HOME'), 'post_process_subprocess.sh'), os.path.join(os.getenv('DATA_DIR'), 'assets', 'ironiq_whatif', "success_lines.txt")], capture_output=True)

        matches = p2.stdout.decode('utf-8').split('\n')

        subprocess.run(['rm', os.path.join(os.getenv('DATA_DIR'), 'assets', 'ironiq_whatif', "success_lines.txt")])

        response['success'] = matches

    return response

@app.get("/sysinfo/assets/{asset_id}/ironiq")
def well_ironiq(asset_id: str, st_dt: str, et_dt: str):
    '''Get data between start_date and end_date'''

    p1 = subprocess.run(['bash', os.path.join(os.getenv("SCRIPTS_DIR"), "ironiq_getWell.sh"), "dba_access", "novadb", asset_id, st_dt, et_dt], capture_output=True)

    if p1.returncode > 0:
        return "No data found"

    import pandas as pd

    df = pd.read_csv(os.path.join(os.getenv("DATA_DIR"), "assets", "ironiq_whatif", "results1.csv"))

    subprocess.run(['rm', os.path.join(os.getenv('DATA_DIR'), 'assets', 'ironiq_whatif', "results1.csv")])

    return json.dumps(df.to_dict(orient='records'))


@app.get("/sysinfo/assets/{asset_id}/quorum")
def read_assets_ironiq(asset_id: str, st_dt: Annotated[str, Query(max_length=10)], et_dt: Annotated[str, Query(max_length=10)]):
    '''Get data between start_date and end_date'''

    p1 = subprocess.run(['bash', os.path.join(os.getenv("SCRIPTS_DIR"), "quorum_getWell.sh"), "dba_access", "novadb", asset_id, st_dt, et_dt], capture_output=True)

    if p1.returncode > 0:
        return "No data found"

    import pandas as pd

    df = pd.read_csv(os.path.join(os.getenv("DATA_DIR"), "assets", "quorum_whatif", "results.csv"))

    subprocess.run(['rm', os.path.join(os.getenv('DATA_DIR'), 'assets', 'quorum_whatif', "results.csv")])

    return json.dumps(df.to_dict(orient='records'))

