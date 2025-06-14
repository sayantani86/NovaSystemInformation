import os
import subprocess
import pandas as pd
from typing import Annotated
from fastapi import APIRouter, Query, HTTPException

router = APIRouter(
    prefix="/wells",
)

@router.get("/{asset_id}")
def read_assets(asset_id: str):
    '''Get details of an asset type'''

    p1 = subprocess.run(['bash', os.path.join(os.getenv("SCRIPTS_DIR"), "getWellDetails.sh"), "dba_access", "novadb", asset_id], capture_output=True)

    if p1.returncode > 0:
        # Error block
        with open(os.path.join(os.getenv('DATA_DIR'), 'assets', "wells", "error_lines.txt"), "w") as f:
            f.write(p1.stderr.decode('utf8'))

        p2 = subprocess.run(['grep', 'ERROR', os.path.join(os.getenv('DATA_DIR'), 'assets', "wells","error_lines.txt")], capture_output=True)

        subprocess.run(['rm', os.path.join(os.getenv('DATA_DIR'), 'assets', "wells", "error_lines.txt")])

        error_lines = p2.stdout.decode('utf8').split('\n')

        raise HTTPException(status_code=400, detail=error_lines[0].replace('ERROR:', '').strip())

    df = pd.read_csv(os.path.join(os.getenv("DATA_DIR"), "assets", "wells", "results.csv"))

    subprocess.run(['rm', os.path.join(os.getenv('DATA_DIR'), 'assets', "wells", "results.csv")])

    return df.to_dict(orient='records')

@router.get("/{asset_id}/production_data")
def read_assets_ironiq(asset_id: str, st_dt: Annotated[str, Query(max_length=10)], et_dt: Annotated[str, Query(max_length=10)]):
    '''Get data between start_date and end_date'''

    p1 = subprocess.run(['bash', os.path.join(os.getenv("SCRIPTS_DIR"), "quorum_getWell.sh"), "dba_access", "novadb", asset_id, st_dt, et_dt], capture_output=True)

    if p1.returncode > 0:
        return "No data found"

    df = pd.read_csv(os.path.join(os.getenv("DATA_DIR"), "assets", "quorum_whatif", "results.csv"))

    subprocess.run(['rm', os.path.join(os.getenv('DATA_DIR'), 'assets', 'quorum_whatif', "results.csv")])

    return df.to_dict(orient='records')
