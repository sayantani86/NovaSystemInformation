import os
import json
import subprocess
from datetime import datetime
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def root():
    return {"message": "Hello World"}

@app.get("/sysinfo/assets/{asset_id}")
def read_assets(asset_id: str):
    '''Get details of an asset type'''

    p1 = subprocess.run(['bash', os.path.join(os.getenv("SCRIPTS_DIR"), "getWellDetails.sh"), "dba_access", "novadb", asset_id], capture_output=True)

    response = {}

    if p1.returncode > 0:
        # Error block
        with open(os.path.join(os.getenv('DATA_DIR'), 'assets', "map", "error_lines.txt"), "w") as f:
            f.write(p1.stderr.decode('utf8'))

        p2 = subprocess.run(['grep', 'ERROR', os.path.join(os.getenv('DATA_DIR'), 'assets',"map",  "error_lines.txt")], capture_output=True)
        
        subprocess.run(['rm', os.path.join(os.getenv('DATA_DIR'), 'assets', "map", "error_lines.txt")])

        error_lines = p2.stdout.decode('utf8').split('\n')

        response['error'] = error_lines[0].replace('ERROR:', '').strip()
    else:
        import pandas as pd

        df = pd.read_csv(os.path.join(os.getenv("DATA_DIR"), "assets", "map", "results.csv"))

        subprocess.run(['rm', os.path.join(os.getenv('DATA_DIR'), 'assets', "map", "results.csv")])

        response['success'] = json.dumps(df.to_dict(orient='records'))

    return response

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
def read_assets_ironiq(asset_id: str, st_dt: str, et_dt: str):
    '''Get data between start_date and end_date'''

    p1 = subprocess.run(['bash', os.path.join(os.getenv("SCRIPTS_DIR"), "quorum_getWell.sh"), "dba_access", "novadb", asset_id, st_dt, et_dt], capture_output=True)

    if p1.returncode > 0:
        return "No data found"

    import pandas as pd

    df = pd.read_csv(os.path.join(os.getenv("DATA_DIR"), "assets", "quorum_whatif", "results.csv"))

    subprocess.run(['rm', os.path.join(os.getenv('DATA_DIR'), 'assets', 'quorum_whatif', "results.csv")])

    return json.dumps(df.to_dict(orient='records'))

@app.get("/sysinfo/maps")
def map_data():
    import psycopg

    with psycopg.connect("dbname=novadb user=dba_access password=avon123") as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT * FROM  maps.shapefiles")
            rs = cur.fetchall()
            conn.commit()
    
    return json.dumps(rs)
