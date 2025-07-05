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
                        SELECT description, pv_wc_id as ref_id, mth_1st_activity, geometry, longitude::float, latitude::float FROM maps.wells_in_3_datasources UNION
                        SELECT description, pv_wc_id as ref_id, mth_1st_activity, geometry, longitude::float, latitude::float FROM maps.baytex_wells_not_in_master_in_quorum UNION
                        SELECT description, pv_wc_id as ref_id, mth_1st_activity, geometry, longitude::float, latitude::float FROM maps.master_wells_in_baytex_not_in_quorum UNION
                        SELECT description, pv_wc_id as ref_id, mth_1st_activity, geometry, longitude::float, latitude::float FROM maps.master_wells_not_in_baytex_in_quorum
                    """)
        rs = cur.fetchall()
        conn.commit()

df = pd.DataFrame(rs)
print(df.shape)

df1 = df.loc[df['geometry'].isnull() & df['longitude'].notnull()]

df1['geometry'] = gpd.GeoSeries(gpd.points_from_xy(df1['longitude'], df1['latitude']), crs=4326)

df['geometry'] = df['geometry'].apply(lambda x: shapely.wkt.loads(x))

df.loc[df['geometry'].isnull() & df['longitude'].notnull(), 'geometry'] = df1['geometry']

df.rename(columns={'description': 'Well Name'}, inplace=True)

# EPSG:2236 corordinates are in feet
#geometry = gpd.GeoSeries(gpd.points_from_xy(df['SHL X'], df['SHL Y']), crs=2236)
#geometry = geometry.to_crs("EPSG:4326")

gdf = gpd.GeoDataFrame(df, geometry=df['geometry'], crs="EPSG:4326")
gdf = gdf.set_index('Well Name')

# Convert to crs 4326
#geometry = geometry.to_crs("EPSG:4326")
#gdf = gdf.set_geometry(geometry)

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

gdf_pipeline['Symbol'] = 'Pipelines'

gdf_pipeline.loc[(gdf_pipeline['SYS_NM'].isnull() & gdf_pipeline['SUBSYS_NM'].isnull()), 'SYS_NM'] = 'Undisclosed'

gdf_pipeline.to_crs("EPSG:4326").to_file('pipelines.geojson', driver='GeoJSON')

# -------------------------------
#          METERS
# ------------------------------

metersDF = pd.read_excel(os.path.join(os.getenv('DATA_DIR'), 'Files', 'ETC_Meters.xlsx'))
gdf_meters = gpd.GeoDataFrame(metersDF, geometry=gpd.points_from_xy(metersDF['LONG'], metersDF['LAT']), crs="EPSG:4326")
gdf_meters['Symbol'] = "Meters"

#gdf_meters['centroid'] = gdf_meters.geometry.to_crs(3857).centroid
#gdf_meters["distance"] = gdf_meters["centroid"].distance(gdf_meters['centroid'].iloc[0])
gdf_meters[['Name', 'Symbol', 'geometry']].to_file('meters.geojson', driver='GeoJSON')

# -------------------------------
#          COMPRESSORS
# -------------------------------

compressorsDF = pd.read_excel(os.path.join(os.getenv('DATA_DIR'), 'Files', 'Lavaca_Compressors.xlsx'))
gdf_compressors = gpd.GeoDataFrame(compressorsDF, geometry=gpd.points_from_xy(compressorsDF['LONG'], compressorsDF['LAT']), crs="EPSG:4326")
gdf_compressors['Symbol'] = "Compressors"
gdf_compressors[['Name', 'Symbol', 'geometry']].to_file('compressors.geojson', driver='GeoJSON')

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

#distances = []
#nearby_lease = []

pipeline_distances = []
nearby_pipelines = []

#meter_distances = []
#nearby_meters = []

#compressor_distances = []
#nearby_compressors = []

for (index, point) in enumerate(gdf_3857.geometry):
    print(index, ref_ids.values[index])
    
    #point_distances = lease_3857.geometry.apply(lambda line_string: calculate_distance(line_string, point))
    #distances.extend(list(zip([ref_ids.values[index]] * len(point_distances), lease_3857['Comments'], point_distances)))

    p_distances = pipeline_3857.geometry.apply(lambda line_string: calculate_distance(line_string, point))
    
    pipeline_distances.extend(list(zip([ref_ids.values[index]] * len(p_distances), pipeline_3857['SYS_NM'] + '_' + pipeline_3857['SUBSYS_NM'], p_distances)))

    #m_distances = meters_3857.geometry.apply(lambda line_string: calculate_distance(line_string, point))
    #meter_distances.extend(list(zip([ref_ids.values[index]] * len(m_distances), meters_3857['Name'], m_distances)))

    #c_distances = compressors_3857.geometry.apply(lambda line_string: calculate_distance(line_string, point))
    #compressor_distances.extend(list(zip([ref_ids.values[index]] * len(c_distances), compressors_3857['Name'], c_distances)))

#res = pd.DataFrame(distances)
#gb = res[res[2] <= 2].groupby([0])

res1 = pd.DataFrame(pipeline_distances)

gb1 = res1[res1[2] <= 2].groupby([0])

#res2 = pd.DataFrame(meter_distances)
#gb2 = res2[res2[2] <= 2].groupby([0])

#res3 = pd.DataFrame(compressor_distances)
#gb3 = res3[res3[2] <= 2].groupby([0])

#for grp in gb.groups:
#    nearby_lease.append((grp, "|".join(gb.get_group(grp)[1].dropna().drop_duplicates().values)))

for grp in gb1.groups:
    nearby_pipelines.append((grp, "|".join(gb1.get_group(grp)[1].dropna().drop_duplicates().values)))

#for grp in gb2.groups:
#    nearby_meters.append((grp, "|".join(gb2.get_group(grp)[1].dropna().drop_duplicates().values)))

#for grp in gb3.groups:
#    nearby_compressors.append((grp, "|".join(gb3.get_group(grp)[1].dropna().drop_duplicates().values)))

#pd.DataFrame(nearby_lease).to_csv('nearby_lease_to_wells.csv', index=False)

pd.DataFrame(nearby_pipelines).to_csv('nearby_pipelines_to_wells.csv', index=False)

#pd.DataFrame(nearby_meters).to_csv('nearby_meters_to_wells.csv', index=False)

#pd.DataFrame(nearby_compressors).to_csv('nearby_compressors_to_wells.csv', index=False)

te = time.time()

print(te - ts)
