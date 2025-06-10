import os
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

    with psycopg.connect("dbname=novadb user=dba_access password=avon123", row_factory=dict_row) as conn:
        with conn.cursor() as cur:
                cur.execute("SELECT features FROM maps.shapefiles")
                rs = cur.fetchall()
                conn.commit()

    return rs

@router.get("/{asset_id}")
def map_data(asset_id: str):
    import psycopg
    from psycopg.rows import dict_row

    with psycopg.connect("dbname=novadb user=dba_access password=avon123", row_factory=dict_row) as conn:
        with conn.cursor() as cur:
                cur.execute("SELECT features FROM maps.shapefiles WHERE symbol ILIKE %s", (asset_id,))
                rs = cur.fetchall()
                conn.commit()

    return rs
