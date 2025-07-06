CREATE VIEW maps.wells_in_3_datasources AS SELECT * FROM (select description, pv_wc_id, county, state, mth_1st_activity::date, well_name, enertia_id, geometry, longitude, latitude, shl_x, shl_y, wellname, refid, firstproductiondate::date, foreman, gl1, gl2, "GL1 Range"::varchar, "GL2 Range"::varchar, ROW_NUMBER() over (PARTITION BY description) AS RN from maps.wells_merged_by_name 
        WHERE enertia_id = pv_wc_id and pv_wc_id = refid) t WHERE t.RN = 1;

CREATE VIEW maps.baytex_wells_not_in_master_in_quorum as (select description, pv_wc_id, county, state, mth_1st_activity::date, well_name, enertia_id, geometry, longitude, latitude, shl_x, shl_y, wellname, refid, firstproductiondate::date, foreman, gl1, gl2, "GL1 Range"::varchar, "GL2 Range"::varchar, ROW_NUMBER() over (PARTITION BY well_name) AS RN from maps.wells_merged_by_name WHERE enertia_id = refid and enertia_id NOT IN (select enertia_id from maps.wells_in_3_datasources) order by well_name);

CREATE VIEW maps.master_wells_not_in_baytex_in_quorum as (select description, pv_wc_id, county, state, mth_1st_activity::date, well_name, enertia_id, geometry, longitude, latitude, shl_x, shl_y, wellname, refid, firstproductiondate::date, foreman, gl1, gl2, "GL1 Range"::varchar, "GL2 Range"::varchar, ROW_NUMBER() over (PARTITION BY well_name) AS RN from maps.wells_merged_by_name WHERE enertia_id IS NULL and pv_wc_id = refid order by description);

CREATE VIEW maps.master_wells_in_baytex_not_in_quorum as (select description, pv_wc_id, county, state, mth_1st_activity::date, well_name, enertia_id, geometry, longitude, latitude, shl_x, shl_y, wellname, refid, firstproductiondate::date, foreman, gl1, gl2, "GL1 Range"::varchar, "GL2 Range"::varchar, ROW_NUMBER() over (PARTITION BY well_name) AS RN from maps.wells_merged_by_name WHERE pv_wc_id = enertia_id and refid IS NULL order by description);

CREATE VIEW maps.master_wells_not_in_baytex_not_in_quorum as (select description, pv_wc_id, county, state, mth_1st_activity::date, well_name, enertia_id, geometry, longitude, latitude, shl_x, shl_y, wellname, refid, firstproductiondate::date, foreman, gl1, gl2, "GL1 Range"::varchar, "GL2 Range"::varchar, ROW_NUMBER() over (PARTITION BY description) AS RN from maps.wells_merged_by_name WHERE enertia_id IS NULL and refid IS NULL and NOT mth_1st_activity ILIKE 'Shut%in' order by description);


