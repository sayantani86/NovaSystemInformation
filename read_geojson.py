import geojson
import psycopg
import json
import geopandas as gpd
import time

t1 = time.time()

with open("wells.geojson") as f:
    gj = geojson.load(f)

with open("lease.geojson") as f:
    gj_lease = geojson.load(f)

with open("pipelines.geojson") as f:
    gj_pipelines = geojson.load(f)

with open("meters.geojson") as f:
    gj_meters = geojson.load(f)

with open("compressors.geojson") as f:
    gj_compressors = geojson.load(f)

#with psycopg.connect("dbname=novadb user=dba_access password=avon123") as conn:
#    with conn.cursor() as cur:
#        cur.execute("INSERT INTO maps.shapefiles(name,geometry) VALUES (%s, %s)",("wells", json.dumps(gj['features'])))

#        cur.execute("INSERT INTO maps.shapefiles(name,geometry) VALUES (%s, %s)",("bte_lease", json.dumps(gj_lease['features'])))

#        cur.execute("INSERT INTO maps.shapefiles(name,geometry) VALUES (%s, %s)",("pipelines", json.dumps(gj_pipelines['features'])))

#        cur.execute("INSERT INTO maps.shapefiles(name,geometry) VALUES (%s, %s)",("meters", json.dumps(gj_meters['features'])))

#        cur.execute("INSERT INTO maps.shapefiles(name,geometry) VALUES (%s, %s)",("compressors", json.dumps(gj_compressors['features'])))

#        conn.commit()


