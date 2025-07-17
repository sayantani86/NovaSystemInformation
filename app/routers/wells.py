import os
import pandas as pd
import subprocess
import psycopg
import time
from psycopg.rows import dict_row
from typing import Annotated
from fastapi import APIRouter, Query, HTTPException, Request

from .models import *
from ..auth import *

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
async def read_assets(asset_id: str, request: Request = None):
    """Retrieves the details of a well.All information are from Quorum database and is not dependent on time

    asset_id: Unique identifier of the asset
    """
   
    token = await verify_jwt_from_request(request)

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
                                w_foreman as "Foreman",
                                w_gl1 as "Lift1",
                                w_gl1_range as "Lift1 duration",
                                w_gl2 as "Lift2",
                                w_gl2_range as "Lift2 duration"
                FROM getWellDetails({asset_id})""")

                rs = cur.fetchall()
                conn.commit()
            except Exception as e:
                print(e)
                raise HTTPException(
                    status_code=500, detail="The server has encountered an error"
                )
    return rs

@router.get("/{asset_id}/quorum")
def get_quorum_data(asset_id: str, st_dt: Annotated[str, Query(max_length=10)], et_dt: Annotated[str, Query(max_length=10)], request: Request = None):
    '''Get data between start_date and end_date'''

    p1 = subprocess.run(['bash', os.path.join(os.getenv("SCRIPTS_DIR"), "quorum_getWell.sh"), "dba_access", "novadb", asset_id, st_dt, et_dt], capture_output=True)
    if p1.returncode > 0:
        return p1.stderr

    df = pd.read_csv(os.path.join(os.getenv("DATA_DIR"), "assets", "quorum_whatif", "results.csv"))
    
    subprocess.run(['rm', os.path.join(os.getenv('DATA_DIR'), 'assets', 'quorum_whatif', "results.csv")])

    return df.to_dict(orient='records')

@router.get("/{asset_id}/production_data")
async def get_production_data(asset_id: str, st_dt: Annotated[str, Query(max_length=10)], et_dt: Annotated[str, Query(max_length=10)], request: Request = None):

    token = await verify_jwt_from_request(request)

    asset_id_sub = asset_id.replace('.01', '01')

    with psycopg.connect("dbname=novadb user=dba_access host=172.30.2.104 password=avon123", row_factory=dict_row) as conn:
        with conn.cursor() as cur:
                cur.execute(f"SELECT * FROM getRangedDataFromQuorumByWell('{asset_id}', '{st_dt}', '{et_dt}')")
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
        'q_shutin_flag3': 'shutin_flag3',
        'q_allocatedproductionoilvolume': 'allocatedproductionoilvolume',
        'q_allocatedproductionoilvolume_lag1': 'allocatedproductionoilvolume_lag1',
        'q_wltype_encoded': 'wltype_encoded'
    }, inplace=True)

    return df.to_dict(orient='records')

@router.post("/")
async def getWells(item: WhatIfRequest, request: Request = None):
    """Retrieves the production variables recorded in Quorum database for a group of wells

    item: An object of a list of RefId and a date range for the group
    """

    token = await verify_jwt_from_request(request)

    actionableInputs = tuple(zip(item.productionWellList, [item.startDate] * len(item.productionWellList), [item.endDate] * len(item.productionWellList)))

    req = "'{" + "\"productionWellList\":" + "[" + ",".join(map(str, item.productionWellList)) + "]" + ", \"startDate\": \"" + item.startDate + "\", \"endDate\": \"" + item.endDate  + "\"}'" 

    ts = time.time()

    with psycopg.connect("dbname=novadb user=dba_access host=172.30.2.104 password=avon123", row_factory=dict_row) as conn:
        with conn.cursor() as cur:
                #cur.execute("DROP TABLE IF EXISTS quorum_whatif.whatif_inputs;")
                
                #cur.execute("CREATE TABLE quorum_whatif.whatif_inputs(refid float, start_date varchar, end_date varchar);")

                #cur.executemany(f"INSERT INTO quorum_whatif.whatif_inputs(refid, start_date, end_date) values (%s, %s, %s)", actionableInputs)

                cur.execute(f"""SELECT
                                q_wellname as wellname,
                                q_refid as refid,
                                q_entry_date as entry_date,
                                q_sequential_month as sequential_month,
                                q_sequential_day as sequential_day,
                                q_linepressure as linepressure,
                                q_casingpressure as casingpressure,
                                q_flowingtubingpressure as flowingtubingpressure,
                                q_allocatedgasinjectionvolume as allocatedgasinjectionvolume,
                                q_choke as choke,
                                q_welllift_flag as welllift_flag,
                                q_shutin_flag3 as shutin_flag3,
                                q_allocatedproductionoilvolume as allocatedproductionoilvolume,
                                q_allocatedproductionoilvolume_lag1 as allocatedproductionoilvolume_lag1,
                                q_wltype_encoded as wltype_encoded
                            FROM 
                                getWhatIfInputsForGroupedWells_1({req});""")

                

                rs = cur.fetchall()
                
                conn.commit()

    print(f"{time.time() - ts}")

    return rs

@router.post("/nearby_components")
async def get_components_within_two_miles(
        item: NearbyComponentRequest, request: Request = None
    ):
    """Get nearby components within 2 miles radius of a well.The results are precomputed and loaded when queried

    asset_id: Unique identifier of the asset
    """
  
    token = await verify_jwt_from_request(request)

    wellNames = "'{" + ",".join(map(lambda x: str(x), item.productionWellList)) + "}'"

    req = "'{" + f'"productionWellList": {item.productionWellList}' + "}'::jsonb"

    with psycopg.connect("dbname=novadb user=dba_access host=172.30.2.104 password=avon123", row_factory=dict_row) as conn:
        with conn.cursor() as cur:
                sql = f"""SELECT * FROM fetchNearbyComponentsNew({req});"""
                cur.execute(sql)
                rs = cur.fetchall()
                conn.commit()

    df = pd.DataFrame(rs)

    return df.to_dict(orient='records')

@router.post("/multiwelldates")
async def get_common_period(
        item: NearbyComponentRequest, request: Request = None
    ):

    token = await verify_jwt_from_request(request)

    req = "'{" + f'"productionWellList": {item.productionWellList}' + "}'::jsonb"

    min_entry_date = None
    max_entry_date = None

    with psycopg.connect("dbname=novadb user=dba_access host=172.30.2.104 password=avon123", row_factory=dict_row) as conn:
        with conn.cursor() as cur:

            sql = f"""SELECT max(min_date) as cal_min_date FROM (SELECT * FROM get_multiwells_overlapping_period({req})) t;"""

            cur.execute(sql)
            
            min_entry_date = cur.fetchone()

            cur.execute(f"""SELECT min(max_date) as cal_max_date FROM (SELECT * FROM get_multiwells_overlapping_period({req})) t;""")

            max_entry_date = cur.fetchone()

            conn.commit()

   
    return (min_entry_date, max_entry_date)
