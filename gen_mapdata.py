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

df = pd.read_csv(os.path.join(os.getenv('DATA_DIR'), 'Files', 'Baytex_Wells.csv'))

#df['geometry'] = df['geometry'].apply(lambda x: shapely.wkt.loads(x))

# EPSG:2236 corordinates are in feet
geometry = gpd.GeoSeries(gpd.points_from_xy(df['SHL X'], df['SHL Y']), crs=2236)
gdf = gpd.GeoDataFrame(df, geometry=geometry)
gdf = gdf.set_index('Well name')

gdf["centroid"] = gdf.centroid
first_point = gdf["centroid"].iloc[0]
gdf["distance"] = gdf["centroid"].distance(first_point)

# Convert to crs 4326
geometry = geometry.to_crs("EPSG:4326")
gdf = gdf.set_geometry(geometry)
gdf['Symbol'] = "Wells"

gdf[['County (SHL)', 'geometry', 'distance', 'Symbol']].to_file('wells.geojson', driver='GeoJSON')

#--------------------------------
#          LEASE
#---------------------------------
gdf_leaseOp = gpd.read_file(os.getenv('GEOM_DIR') + '/BTE_OP_Leasehold_010825.shp', columns=['Comments', 'geometry'])
gdf_leaseOp = gdf_leaseOp.set_geometry("geometry")
gdf_leaseOp = gdf_leaseOp.to_crs("EPSG:4326")
gdf_leaseOp['Symbol'] = "Area"

# EPSG:32040
gdf_leaseNonOp = gpd.read_file(os.getenv('GEOM_DIR') + '/BTE_NonOp_Leasehold_010825.shp', columns=['Comments', 'geometry'])
gdf_leaseNonOp = gdf_leaseNonOp.set_geometry("geometry")
gdf_leaseNonOp = gdf_leaseNonOp.to_crs("EPSG:4326")
gdf_leaseNonOp['Symbol'] = "Area"

pd.concat([gdf_leaseOp, gdf_leaseNonOp]).to_file('lease.geojson', driver='GeoJSON')

#-------------------------------------
#         PIPELINES
#--------------------------------------
p1=subprocess.Popen(['ls', os.path.join(os.getenv('GEOM_DIR'), 'OilGasPipelines')], stdout=subprocess.PIPE)

grepProcess = subprocess.Popen( ["grep", ".shp$"], stdin=p1.stdout, stdout=subprocess.PIPE)

p1.stdout.close()

stdout, stderr = grepProcess.communicate()

gdf_pipeline = pd.DataFrame()

for shp_file in stdout.decode('utf-8').split('\n'):
    if not shp_file:continue

    # EPSG:32040
    df1 = gpd.read_file(os.path.join(os.getenv('GEOM_DIR'), 'OilGasPipelines', shp_file), columns=['OWNER', 'SYS_NM', 'SUBSYS_NM', 'DIAMETER', 'geometry'])
    df1 = df1.set_geometry('geometry')
    df1 = df1.to_crs("EPSG:4326")

    gdf_pipeline = pd.concat([gdf_pipeline, df1])

gdf_pipeline = gdf_pipeline[gdf_pipeline['OWNER'] != 'IRONWOOD']
gdf_pipeline['Symbol'] = 'Pipelines'
gdf_pipeline.to_file('pipelines.geojson', driver='GeoJSON')

# -------------------------------
#          METERS
# ------------------------------

metersDF = pd.read_excel(os.path.join(os.getenv('DATA_DIR'), 'Files', 'ETC_Meters.xlsx'))
gdf_meters = gpd.GeoDataFrame(metersDF, geometry=gpd.points_from_xy(metersDF['LONG'], metersDF['LAT']), crs="EPSG:4326")

gdf_meters['centroid'] = gdf_meters.geometry.to_crs(3857).centroid
gdf_meters["distance"] = gdf_meters["centroid"].distance(gdf_meters['centroid'].iloc[0])

gdf_meters[['Name', 'Symbol', 'geometry', 'distance']].to_file('meters.geojson', driver='GeoJSON')


# -------------------------------
#          COMPRESSORS
# -------------------------------

compressorsDF = pd.read_excel(os.path.join(os.getenv('DATA_DIR'), 'Files', 'Lavaca_Compressors.xlsx'))
gdf_compressors = gpd.GeoDataFrame(compressorsDF, geometry=gpd.points_from_xy(compressorsDF['LONG'], compressorsDF['LAT']), crs="EPSG:4326")
gdf_compressors['centroid'] = gdf_compressors.geometry.to_crs(3857).centroid
gdf_compressors["distance"] = gdf_compressors["centroid"].distance(gdf_compressors['centroid'].iloc[0])

gdf_compressors[['Name', 'Symbol', 'geometry', 'distance']].to_file('compressors.geojson', driver='GeoJSON')

