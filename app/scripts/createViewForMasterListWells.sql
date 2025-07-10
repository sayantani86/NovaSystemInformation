CREATE VIEW maps.wells_in_3_datasources AS 
SELECT * FROM (
	select 
		description, 
		pv_wc_id, 
		description_nowhitespace, 
		county, 
		state, 
		mth_1st_activity, 
		well_name, 
		baytex_wells_nowhitespace, 
		enertia_id,
	       	shl_x,
		shl_y,	
		geometry, 
		wellname,
		refid, 
		quorum_well_nowhitespace,
		longitude,
		latitude,
		firstproductiondate, 
		foreman, 
		gl1, 
		gl2, 
		"GL1 Range"::varchar, 
		"GL2 Range"::varchar, 
		ROW_NUMBER() over (PARTITION BY description) AS RN 
	from 
		maps.wells_merged_by_name 
        WHERE enertia_id = pv_wc_id and pv_wc_id = refid) t WHERE t.RN = 1;

CREATE VIEW maps.master_wells_unmatched_with_baytex as (
        select 
		description, 
		pv_wc_id, 
		description_nowhitespace, 
		county, 
		state, 
		mth_1st_activity, 
		well_name, 
		baytex_wells_nowhitespace, 
		enertia_id,
	       	shl_x,
		shl_y,	
		geometry,
	        wellname,
		refid,
		quorum_well_nowhitespace,	
		longitude, 
		latitude, 
		firstproductiondate, 
		foreman, 
		gl1, 
		gl2, 
		"GL1 Range"::varchar, 
		"GL2 Range"::varchar, 
		ROW_NUMBER() over (PARTITION BY description) AS RN 
        from maps.wells_merged_by_name WHERE pv_wc_id != enertia_id and description_nowhitespace = baytex_wells_nowhitespace and description NOT In (select description from maps.wells_in_3_datasources)
);

CREATE VIEW maps.master_wells_in_quorum_only as (
        select
                description,
                pv_wc_id,
                description_nowhitespace,
                county,
                state,
                mth_1st_activity,
                well_name,
                baytex_wells_nowhitespace,
                enertia_id,
                shl_x,
                shl_y,
                geometry,
                wellname,
                refid,
                quorum_well_nowhitespace,
                longitude,
                latitude,
                firstproductiondate,
                foreman,
                gl1,
                gl2,
                "GL1 Range"::varchar,
                "GL2 Range"::varchar,
                ROW_NUMBER() over (PARTITION BY description) AS RN
        FROM
       		maps.wells_merged_by_name 
	WHERE 
		enertia_id IS NULL and pv_wc_id = refid 
);

CREATE VIEW maps.master_wells_with_geom_only as (
        select
                description,
                pv_wc_id,
                description_nowhitespace,
                county,
                state,
                mth_1st_activity,
                well_name,
                baytex_wells_nowhitespace,
                enertia_id,
                shl_x,
                shl_y,
                geometry,
                wellname,
                refid,
                quorum_well_nowhitespace,
                longitude,
                latitude,
                firstproductiondate,
                foreman,
                gl1,
                gl2,
                "GL1 Range"::varchar,
                "GL2 Range"::varchar,
                ROW_NUMBER() over (PARTITION BY description) AS RN
        FROM
                maps.wells_merged_by_name
        WHERE
		pv_wc_id = enertia_id and wellname IS NULL
);

CREATE VIEW maps.others as (
        select
                description,
                pv_wc_id,
                description_nowhitespace,
                county,
                state,
                mth_1st_activity,
                well_name,
                baytex_wells_nowhitespace,
                enertia_id,
                shl_x,
                shl_y,
                geometry,
                wellname,
                refid,
                quorum_well_nowhitespace,
                longitude,
                latitude,
                firstproductiondate,
                foreman,
                gl1,
                gl2,
                "GL1 Range"::varchar,
                "GL2 Range"::varchar,
                ROW_NUMBER() over (PARTITION BY description) AS RN
        FROM
                maps.wells_merged_by_name
        WHERE
                description NOT IN (
			SELECT description from maps.wells_in_3_datasources UNION 
			SELECT description FROM maps.master_wells_unmatched_with_baytex UNION 
			SELECT description FROM maps.master_wells_in_quorum_only UNION 
			SELECT description FROM maps.master_wells_with_geom_only	
		) 
);

