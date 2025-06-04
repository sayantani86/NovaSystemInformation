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
def read_assets(asset_id: str):
    '''Get details of an asset type'''

    p1 = subprocess.run(['bash', os.path.join(os.getenv("SCRIPTS_DIR"), "searchWell.sh"), "dba_access", "novadb", asset_id], capture_output=True)

    response = {}

    if p1.returncode > 0:
        with open(os.path.join(os.getenv('DATA_DIR'), 'ironiq_whatif_inputs', "error_lines.txt"), "w") as f:
            f.write(p1.stderr.decode('utf8'))

        p2 = subprocess.run(['grep', 'ERROR', os.path.join(os.getenv('DATA_DIR'), 'ironiq_whatif_inputs', "error_lines.txt")], capture_output=True)

        subprocess.run(['rm', os.path.join(os.getenv('DATA_DIR'), 'ironiq_whatif_inputs', "error_lines.txt")], capture_output=True)

        error_lines = p2.stdout.decode('utf8').split('\n')

        response['error'] = error_lines[0].replace('ERROR:', '').strip()
    else:
        with open(os.path.join(os.getenv('DATA_DIR'), 'ironiq_whatif_inputs', "success_lines.txt"), "w") as f:
            f.write(p1.stdout.decode('utf8'))

        p2 = subprocess.run(['bash', 'post_process_subprocess.sh', os.path.join(os.getenv('DATA_DIR'), 'ironiq_whatif_inputs', "success_lines.txt")], capture_output=True)
        
        matches = p2.stdout.decode('utf-8').split('\n')

        subprocess.run(['rm', os.path.join(os.getenv('DATA_DIR'), 'ironiq_whatif_inputs', "success_lines.txt")])

        response['error'] = matches
    
    return response

@app.get("/sysinfo/assets/ironiq/{asset_id}")
def read_assets_ironiq(asset_id: str, st_dt: str, et_dt: str):
    '''Get data between start_date and end_date'''

    p1 = subprocess.run(['bash', os.path.join(os.getenv("SCRIPTS_DIR"), "getWell.sh"), "dba_access", "novadb", asset_id, st_dt, et_dt], capture_output=True)

    if p1.returncode > 0:
        return "No data found"

    import pandas as pd

    df = pd.read_csv(os.path.join(os.getenv("DATA_DIR"), "ironiq_whatif_inputs", "results1.csv"))

    return json.dumps(df.to_dict(orient='records'))
