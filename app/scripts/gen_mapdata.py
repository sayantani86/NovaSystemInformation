import os
import psycopg
from psycopg.rows import namedtuple_row
from psycopg.rows import dict_row
import geopandas as gpd
import pandas as pd
import subprocess
import shapely
import time

t1 = time.time()

#---------------------------------
#       WELLS
#---------------------------------

with psycopg.connect("dbname=novadb user=dba_access password=avon123", row_factory=dict_row) as conn:
    with conn.cursor() as cur:
        cur.execute("""
                        SELECT description, pv_wc_id as ref_id, well_name, wellname, geometry, longitude::float, latitude::float FROM maps.wells_in_3_datasources UNION
                        SELECT description, pv_wc_id as ref_id, well_name, wellname, geometry, longitude::float, latitude::float FROM maps.master_wells_in_quorum_only UNION
                        SELECT description, pv_wc_id as ref_id, well_name, wellname, geometry, longitude::float, latitude::float FROM maps.master_wells_unmatched_with_baytex UNION
                        SELECT description, pv_wc_id as ref_id, well_name, wellname, geometry, longitude::float, latitude::float FROM maps.master_wells_with_geom_only UNION
                        SELECT description, pv_wc_id as ref_id, well_name, wellname, geometry, longitude::float, latitude::float FROM maps.others
                    """)
        rs = cur.fetchall()
        conn.commit()

df = pd.DataFrame(rs)
df = df.drop_duplicates()
print(df.shape)

wells_mape = pd.read_csv(os.path.join(os.getenv('DATA_DIR'), 'wells_small_mape.csv'))

df = df[df['ref_id'].astype(float).isin(wells_mape['refid'].astype(float))]
print(df.shape)

df1 = df.loc[df['geometry'].isnull()]
geometry = gpd.points_from_xy(df1['longitude'], df1['latitude'])
gdf1 = gpd.GeoDataFrame(df1, geometry=geometry, crs="EPSG:4326")
gdf1 = gdf1.set_index('description')

df['geometry'] = df['geometry'].apply(lambda x: shapely.wkt.loads(x))
df = df.set_index('description')

for indx in gdf1.index:
    df.loc[indx, 'geometry'] = gdf1.loc[indx, 'geometry']

df.reset_index(inplace = True)
df.rename(columns={'description': 'Well Name'}, inplace=True)

gdf = gpd.GeoDataFrame(df, geometry=df['geometry'], crs="EPSG:4326")
gdf = gdf.set_index('Well Name')
gdf['Symbol'] = "Wells"
gdf[['geometry', 'Symbol', 'ref_id']].to_file('wells.geojson', driver='GeoJSON')

#--------------------------------
#          LEASE
#---------------------------------

gdf_leaseOp = gpd.read_file(os.getenv('GEOM_DIR') + '/BTE_OP_Leasehold_010825.shp', columns=['Comments', 'geometry', 'Shape_Leng'])
gdf_leaseOp = gdf_leaseOp.set_geometry("geometry")
gdf_leaseOp = gdf_leaseOp.to_crs("EPSG:4326")

gdf_leaseOp['Symbol'] = "Area"

gdf_leaseOp[["Comments", "Symbol", "geometry"]].to_file('lease.geojson', driver='GeoJSON')

#-------------------------------------
#         PIPELINES
#--------------------------------------

p = subprocess.run(["ls " + os.getenv('GEOM_DIR') + " | grep '\(BTE_Gas\|Lavaca_Gas\).*.shp$'"], shell=True, capture_output=True)

gdf_pipeline = pd.DataFrame()

for shp_file in p.stdout.decode('utf-8').split('\n'):
    if not shp_file:continue

    # actual EPSG = EPSG:32040
    df1 = gpd.read_file(os.path.join(os.getenv('GEOM_DIR'), shp_file), columns=['OWNER', 'SYS_NM', 'SUBSYS_NM', 'geometry'])

    gdf_pipeline = pd.concat([gdf_pipeline, df1])

gdf_pipeline = gdf_pipeline.drop_duplicates()

gdf_pipeline = gdf_pipeline.reset_index(drop=True)
gdf_pipeline = gdf_pipeline.reset_index()
gdf_pipeline['Symbol'] = 'Pipelines'

gdf_pipeline.to_crs("EPSG:4326").to_file('pipelines.geojson', driver='GeoJSON')

# -------------------------------
#          METERS
# ------------------------------

#metersDF = pd.read_excel(os.path.join(os.getenv('DATA_DIR'), 'Files', 'ETC_Meters.xlsx'))
#gdf_meters = gpd.GeoDataFrame(metersDF, geometry=gpd.points_from_xy(metersDF['LONG'], metersDF['LAT']), crs="EPSG:4326")
#gdf_meters['Symbol'] = "Meters"
#gdf_meters[['Name', 'Symbol', 'geometry']].to_file('meters.geojson', driver='GeoJSON')

# -------------------------------
#          COMPRESSORS
# -------------------------------

compressorsDF = pd.read_excel(os.path.join(os.getenv('DATA_DIR'), 'Files', 'Lavaca_Compressors.xlsx'))

gdf_compressors = gpd.GeoDataFrame(compressorsDF, geometry=gpd.points_from_xy(compressorsDF['LONG'], compressorsDF['LAT']), crs="EPSG:4326")

#gdf_compressors = gpd.GeoDataFrame(compressorsDF, geometry=gpd.points_from_xy(compressorsDF['LONG'], compressorsDF['LAT']), crs="EPSG:4326")
gdf_compressors['Symbol'] = "Compressors"
gdf_compressors[['Name', 'Symbol', 'geometry']].to_file('compressors.geojson', driver='GeoJSON')

gdf_compressors.to_file('compressors.geojson', driver='GeoJSON')

# ----------- Calculate distance --------------

ts = time.time()

gdf_3857 = gdf.to_crs(3857)


#lease_3857 = gdf_leaseOp.to_crs(3857)

pipeline_3857 = gdf_pipeline.to_crs(3857)

#meters_3857 = gdf_meters.to_crs(3857)

#compressors_3857 = gdf_compressors.to_crs(3857)

def calculate_distance(line_string, point):
    return line_string.distance(point) / 1609.34 # in miles

ref_ids = gdf_3857['ref_id']

pipeline_distances = []
nearby_pipelines = []

for (index, point) in enumerate(gdf_3857.geometry):
    #print(index, ref_ids.values[index])
    
    p_distances = pipeline_3857.geometry.apply(lambda line_string: calculate_distance(line_string, point))

    pipeline_distances.extend(list(zip([ref_ids.values[index]] * len(p_distances), pipeline_3857['index'], pipeline_3857['SYS_NM'], pipeline_3857['SUBSYS_NM'], p_distances)))

res1 = pd.DataFrame(pipeline_distances)

# Retain distances within 2 miles

res1 = res1[res1[4] <= 2]

pd.DataFrame(res1)[[0, 1, 2, 3]].to_csv('pipelines_in_2miles.csv', index=False)

"""gb1 = res1.groupby([0, 1])

for grp in gb1.groups:
    nearby_pipelines.append((grp[0], grp[1], "|".join(gb1.get_group(grp)[2].dropna().drop_duplicates().values)))

pd.DataFrame(nearby_pipelines).to_csv('nearby_pipelines_to_wells.csv', index=False)"""

te = time.time()

print(te - ts)
