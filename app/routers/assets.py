import os
import subprocess
from fastapi import APIRouter, HTTPException

router = APIRouter(
    prefix="/assets",
)

@router.get("/geojson")
def get_geo_data():
    import geojson

    try:
        with open(os.path.join(os.getenv('DATA_DIR'), 'geojson', "wells.geojson")) as f:
            gj = geojson.load(f)

        with open(os.path.join(os.getenv('DATA_DIR'), 'geojson', "lease.geojson")) as f:
            gj_lease = geojson.load(f)

        with open(os.path.join(os.getenv('DATA_DIR'), 'geojson',  "pipelines.geojson")) as f:
            gj_pipelines = geojson.load(f)

        with open(os.path.join(os.getenv('DATA_DIR'), 'geojson', "meters.geojson")) as f:
            gj_meters = geojson.load(f)

        with open(os.path.join(os.getenv('DATA_DIR'), 'geojson', "compressors.geojson")) as f:
            gj_compressors = geojson.load(f)

        features = []

        features.extend(gj['features'])
        features.extend(gj_lease['features'])
        features.extend(gj_pipelines['features'])
        features.extend(gj_meters['features'])
        features.extend(gj_compressors['features'])
    except Exception as e:
        print(e)
        raise HTTPException(status_code=500, detail="The code has encountered an exception.PLease wait while we debug the problem.")

    return features

@router.get("/")
def map_data():
    import psycopg
    from psycopg.rows import dict_row

    with psycopg.connect("dbname=novadb user=dba_access host=172.30.2.104 password=avon123") as conn:
        with conn.cursor() as cur:
                cur.execute("SELECT features FROM maps.shapefiles")
                rs = cur.fetchall()
                conn.commit()

    resp = []

    for item in rs:
        resp.extend(item[0])
    return resp

@router.get("/{asset_type}")
def map_data(asset_type: str):
    import psycopg
    from psycopg.rows import dict_row

    with psycopg.connect("dbname=novadb user=dba_access host=172.30.2.104 password=avon123", row_factory=dict_row) as conn:
        with conn.cursor() as cur:
                cur.execute("SELECT features FROM maps.shapefiles WHERE symbol ILIKE %s", (asset_type,))
                rs = cur.fetchall()
                conn.commit()

    return rs

@router.get("/{asset_type}/{asset_name}/{asset_id}")
def read_assets(asset_type: str, asset_name: str, asset_id: str):
    '''Get details of an asset type'''

    p1 = subprocess.run(['bash', os.path.join(os.getenv("SCRIPTS_DIR"), "getWellDetails.sh"), "dba_access", "novadb", asset_name, asset_id], capture_output=True)

    if p1.returncode > 0:
        # Error block
        with open(os.path.join(os.getenv('DATA_DIR'), 'assets', "wells", "error_lines.txt"), "w") as f:
            f.write(p1.stderr.decode('utf8'))

        p2 = subprocess.run(['grep', 'ERROR', os.path.join(os.getenv('DATA_DIR'), 'assets', "wells","error_lines.txt")], capture_output=True)

        subprocess.run(['rm', os.path.join(os.getenv('DATA_DIR'), 'assets', "wells", "error_lines.txt")])

        error_lines = p2.stdout.decode('utf8').split('\n')

        raise HTTPException(status_code=400, detail=error_lines[0].replace('ERROR:', '').strip())

    import pandas as pd

    df = pd.read_csv(os.path.join(os.getenv("DATA_DIR"), "assets", "wells", "results.csv"))

    print(df)

    subprocess.run(['rm', os.path.join(os.getenv('DATA_DIR'), 'assets', "wells", "results.csv")])

    return df.to_dict(orient='records')
