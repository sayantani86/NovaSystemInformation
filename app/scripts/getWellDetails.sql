DROP FUNCTION getWellDetails(refid numeric);

CREATE OR REPLACE FUNCTION getWellDetails(refid numeric) 
 RETURNS TABLE (
	w_description varchar,
	w_county varchar,
	w_state varchar,
	w_pv_wc_id numeric,
	w_mth_1st_activity date,
	quorum_firstproductiondate date,
	shlx varchar,
	shly varchar,
	w_longitude varchar,
	w_latitude varchar,
	w_foreman varchar,
	w_gl1 varchar,
	w_gl1_range varchar,
	w_gl2 varchar,
	w_gl2_range varchar
) AS 
$$
BEGIN
	RAISE NOTICE 'RefId = %', refid;

	RETURN QUERY 
			SELECT description,
				county, 
				state, 
				pv_wc_id::numeric,
				mth_1st_activity::date,
				firstproductiondate::date,
				shl_x, 
				shl_y,
				longitude::varchar,
				latitude::varchar,
				foreman, 
				gl1, 
				"GL1 Range"::varchar, 
				gl2, 
				"GL2 Range"::varchar
			 FROM 
				(
					SELECT * FROM maps.wells_in_3_datasources UNION
					SELECT * FROM maps.master_wells_in_quorum_only UNION
					SELECT * FROM maps.master_wells_unmatched_with_baytex UNION
					SELECT * FROM maps.master_wells_with_geom_only UNION
					SELECT * FROM maps.others
				) a
			WHERE 
				a.pv_wc_id::numeric = getWellDetails.refid::numeric;

END;
$$ LANGUAGE plpgsql;
