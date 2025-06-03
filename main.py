import os
import subprocess
from datetime import datetime
from fastapi import FastAPI
from pydantic import BaseModel
import json

app = FastAPI()

class IronIQItem(BaseModel):
    id: int
    timestamp: datetime
    value: float
    point_name: str
    equipment: str
    parent_equipment_name: str
    equipment_type: str

@app.get("/")
def root():
    return {"message": "Hello World"}

@app.get("/sysinfo/assets/{asset_id}")
def read_asset(asset_id: str):
    '''Get details of an asset type'''

    p1 = subprocess.run(['bash', os.path.join(os.getenv("SCRIPTS_DIR"), "searchWell.sh"), "dba_access", "novadb", asset_id], capture_output=True)

    with open("error_lines.txt", "w") as f:
        f.write(p1.stderr.decode('utf8'))

    p2 = subprocess.run(['grep', 'ERROR', "error_lines.txt"], capture_output=True)

    subprocess.run(['rm', "error_lines.txt"], capture_output=True)

    error_lines = p2.stdout.decode('utf8').split('\n')

    return {"message": error_lines[0].replace('ERROR:', '').strip()}

@app.get("/sysinfo/assets/ironiq/{asset_id}")
def read_asset_ironiq(asset_id: str, st_dt: str, et_dt: str):
    '''Get data between start_date and end_date'''

    p1 = subprocess.run(['bash', os.path.join(os.getenv("SCRIPTS_DIR"), "getWell.sh"), "dba_access", "novadb", asset_id, st_dt, et_dt], capture_output=True)

    if p1.returncode > 0:
        return "No data found"

    import pandas as pd

    df = pd.read_csv("results1.csv")

    return json.dumps(df.to_dict(orient='records'))
