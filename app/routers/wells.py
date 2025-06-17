import os
import pandas as pd
import subprocess
from typing import Annotated
from fastapi import APIRouter, Query,  HTTPException

from .models import *

router = APIRouter(
    prefix="/wells",
)

@router.get("/{asset_id}i/v1")
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

@router.get("/{asset_id}")
def read_assets(asset_id: str):
    '''Get details of an asset type'''
    
    import psycopg
    from psycopg.rows import dict_row

    with psycopg.connect("dbname=novadb user=dba_access host=172.30.2.104 password=avon123", row_factory=dict_row) as conn:
        with conn.cursor() as cur:
                cur.execute(f"SELECT * FROM getWellDetails('{asset_id}')")
                rs = cur.fetchall()
                conn.commit()

    return rs

@router.get("/{asset_id}/quorum")
def get_quorum_data(asset_id: str, st_dt: Annotated[str, Query(max_length=10)], et_dt: Annotated[str, Query(max_length=10)]):
    '''Get data between start_date and end_date'''

    p1 = subprocess.run(['bash', os.path.join(os.getenv("SCRIPTS_DIR"), "quorum_getWell.sh"), "dba_access", "novadb", asset_id, st_dt, et_dt], capture_output=True)
    print(p1)

    if p1.returncode > 0:
        return p1.stderr

    df = pd.read_csv(os.path.join(os.getenv("DATA_DIR"), "assets", "quorum_whatif", "results.csv"))
    
    subprocess.run(['rm', os.path.join(os.getenv('DATA_DIR'), 'assets', 'quorum_whatif', "results.csv")])

    return df.to_dict(orient='records')

@router.get("/{asset_id}/production_data")
def get_production_data(asset_id: str, st_dt: Annotated[str, Query(max_length=10)], et_dt: Annotated[str, Query(max_length=10)]):

    import psycopg
    from psycopg.rows import dict_row

    asset_id_sub = asset_id.replace('.01', '01')

    with psycopg.connect("dbname=novadb user=dba_access host=172.30.2.104 password=avon123", row_factory=dict_row) as conn:
        with conn.cursor() as cur:
                cur.execute(f"SELECT * FROM getRangedDataFromQuorumByWell('{asset_id}', asset_id_sub, '{st_dt}', '{et_dt}')")
                rs = cur.fetchall()
                conn.commit()

    return rs

@router.post("/")
def getWells(item: WhatIfRequest):
   
    actionableInputs = list(zip(item.productionWellList, [item.startDate]*len(item.productionWellList), [item.endDate]*len(item.productionWellList), [item.actionableParameters.choke] * len(item.productionWellList)))

    print(actionableInputs)

    import psycopg

    with psycopg.connect("dbname=novadb user=dba_access host=172.30.2.104 password=avon123") as conn:
         with conn.cursor() as cur:
             cur.execute(f"CREATE TABLE quorum_whatif.whatif_inputs(refid float, start_date varchar, end_date varchar, choke float)")
             cur.execute("INSERT INTO quorum_whatif.whatif_inputs values (%s, %s, %s, %s) ", actionableInputs)
             conn.commit()

    return item
