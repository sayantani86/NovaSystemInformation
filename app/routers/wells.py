import os
import pandas as pd
import subprocess
import psycopg
from psycopg.rows import dict_row
from typing import Annotated
from fastapi import APIRouter, Query, HTTPException

from .models import *

router = APIRouter(
    prefix="/wells",
)

@router.get("/{asset_id}/v1")
def read_assets(asset_id: str):
    """Retrieves the details of a well.All information are from Quorum database and is not dependent on time

    This is the version which uses shell script to execute the given query.Can be run when psql is installed on source server.

    asset_id: Unique identifier of the asset
    """

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
async def read_assets(asset_id: str):
    """Retrieves the details of a well.All information are from Quorum database and is not dependent on time

    asset_id: Unique identifier of the asset
    """
    
    with psycopg.connect("dbname=novadb user=dba_access host=172.30.2.104 password=avon123", row_factory=dict_row) as conn:
        with conn.cursor() as cur:
            try:
                cur.execute(f"""SELECT 
                                w_description as "Well Name", 
                                w_county as "County",
                                w_state as "State",
                                w_pv_wc_id as "RefID",
                                w_mth_1st_activity as "First activity month",
                                quorum_firstproductiondate as "First production date",
                                shlx as "SHL X",
                                shly as "SHL Y",
                                w_longitude as "Longitude",
                                w_latitude as "Latitude",
                                w_foreman as "Foreman",
                                w_gl1 as "Gas Lift 2",
                                w_gl1_range as "Gas Lift 2 period",
                                w_gl2 as "Gas Lift 1",
                                w_gl2_range as "Gas Lift 1 period"
                FROM getWellDetails('{asset_id}')""")

                rs = cur.fetchall()
                conn.commit()
            except Exception as e:
                print(e)
                raise HTTPException(
                    status_code=500, detail="The server has encountered an error"
                )
    return rs

@router.get("/{asset_id}/quorum")
def get_quorum_data(asset_id: str, st_dt: Annotated[str, Query(max_length=10)], et_dt: Annotated[str, Query(max_length=10)]):
    '''Get data between start_date and end_date'''

    p1 = subprocess.run(['bash', os.path.join(os.getenv("SCRIPTS_DIR"), "quorum_getWell.sh"), "dba_access", "novadb", asset_id, st_dt, et_dt], capture_output=True)
    if p1.returncode > 0:
        return p1.stderr

    df = pd.read_csv(os.path.join(os.getenv("DATA_DIR"), "assets", "quorum_whatif", "results.csv"))
    
    subprocess.run(['rm', os.path.join(os.getenv('DATA_DIR'), 'assets', 'quorum_whatif', "results.csv")])

    return df.to_dict(orient='records')

@router.get("/{asset_id}/production_data")
async def get_production_data(asset_id: str, st_dt: Annotated[str, Query(max_length=10)], et_dt: Annotated[str, Query(max_length=10)]):
    """Retrieves the production variables recorded in quorum database for a well

    asset_id: Unique identifier of the asset
    st_dt: Start date of the range
    et_dt: End date of the range
    """

    asset_id_sub = asset_id.replace('.01', '01')

    print(f"SELECT * FROM getRangedDataFromQuorumByWell('{asset_id}', {asset_id_sub}, '{st_dt}', '{et_dt}')")

    with psycopg.connect("dbname=novadb user=dba_access host=172.30.2.104 password=avon123", row_factory=dict_row) as conn:
        with conn.cursor() as cur:
                cur.execute(f"SELECT * FROM getRangedDataFromQuorumByWell('{asset_id}', {asset_id_sub}, '{st_dt}', '{et_dt}')")
                rs = cur.fetchall()
                conn.commit()

    df = pd.DataFrame(rs)

    df.rename(columns= {
        'q_wellname': 'wellname',
        'q_refid': 'refid',
        'q_entry_date': 'entry_date',
        'q_sequential_month': 'sequential_month',
        'q_sequential_day': 'sequential_day',
        'q_linepressure': 'linepressure',
        'q_casingpressure': 'casingpressure',
        'q_flowingtubingpressure': 'flowingtubingpressure',
        'q_allocatedgasinjectionvolume': 'allocatedgasinjectionvolume',
        'q_choke': 'choke',
        'q_welllift_flag': 'welllift_flag',
        'q_wl_type': 'wl_type',
        'q_shutin_flag1': 'shutin_flag1',
        'q_shutin_flag3': 'shutin_flag3',
        'q_rampup_flag': 'rampup_flag',
        'q_allocatedproductionoilvolume': 'allocatedproductionoilvolume',
        'q_allocatedproductionoilvolume_lag1': 'allocatedproductionoilvolume_lag1',
        'q_allocatedproductionoilvolume_lag2': 'allocatedproductionoilvolume_lag2',
        'q_allocatedproductionoilvolume_lag3': 'allocatedproductionoilvolume_lag3',
        'q_wltype_encoded': 'wltype_encoded'
    }, inplace=True)

    return df.to_dict(orient='records')

@router.post("/")
async def getWells(item: WhatIfRequest):
    """Retrieves the production variables recorded in Quorum database for a group of wells

    item: An object of a list of RefId and a date range for the group
    """

    actionableInputs = tuple(zip(item.productionWellList, [item.startDate]*len(item.productionWellList), [item.endDate]*len(item.productionWellList)))

    with psycopg.connect("dbname=novadb user=dba_access host=172.30.2.104 password=avon123", row_factory=dict_row) as conn:
        with conn.cursor() as cur:
                cur.execute("DROP TABLE IF EXISTS quorum_whatif.whatif_inputs;")

                cur.execute("CREATE TABLE quorum_whatif.whatif_inputs(refid float, start_date varchar, end_date varchar);")

                cur.executemany(f"INSERT INTO quorum_whatif.whatif_inputs(refid, start_date, end_date) values (%s, %s, %s)", actionableInputs)

                cur.execute(f"SELECT * FROM getWhatIfInputsForGroupedWells();")

                rs = cur.fetchall()
                
                conn.commit()

    return rs

@router.post("/nearby_components")
async def get_components_within_two_miles(
        item: NearbyComponentRequest
    ):
    """Get nearby components within 2 miles radius of a well.The results are precomputed and loaded when queried

    asset_id: Unique identifier of the asset
    """
   
    print(item)

    wellNames = "'{" + ",".join(map(lambda x: str(x), item.productionWellList)) + "}'"

    with psycopg.connect("dbname=novadb user=dba_access host=172.30.2.104 password=avon123", row_factory=dict_row) as conn:
        with conn.cursor() as cur:
                sql = f"""SELECT * FROM fetchNearbyComponents({wellNames});"""
               
                cur.execute(sql)

                rs = cur.fetchall()
                
                conn.commit()

    df = pd.DataFrame(rs)
    df.rename(columns= {
        'q_wellname': 'wellname',
        'q_refid': 'refid',
        'q_entry_date': 'entry_date',
        'q_sequential_month': 'sequential_month',
        'q_sequential_day': 'sequential_day',
        'q_linepressure': 'linepressure',
        'q_casingpressure': 'casingpressure',
        'q_flowingtubingpressure': 'flowingtubingpressure',
        'q_allocatedgasinjectionvolume': 'allocatedgasinjectionvolume',
        'q_choke': 'choke',
        'q_welllift_flag': 'welllift_flag',
        'q_wl_type': 'wl_type',
        'q_shutin_flag1': 'shutin_flag1',
        'q_shutin_flag3': 'shutin_flag3',
        'q_rampup_flag': 'rampup_flag',
        'q_allocatedproductionoilvolume': 'allocatedproductionoilvolume',
        'q_allocatedproductionoilvolume_lag1': 'allocatedproductionoilvolume_lag1',
        'q_allocatedproductionoilvolume_lag2': 'allocatedproductionoilvolume_lag2',
        'q_allocatedproductionoilvolume_lag3': 'allocatedproductionoilvolume_lag3',
        'q_wltype_encoded': 'wltype_encoded'
    }, inplace=True)

    return df.to_dict(orient='records')
