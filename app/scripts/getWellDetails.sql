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
	w_gl2_range varchar,
	min_entry_date date,
	max_entry_date date,
	calendar_min date,
	calendar_max date
) AS 
$$
BEGIN
	RAISE NOTICE 'RefId = %', refid;

	RETURN QUERY 
		SELECT b.*, c.min_entry_date,c.max_entry_date, d.calendar_min, d.calendar_max FROM (
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
				a.pv_wc_id::numeric = getWellDetails.refid::numeric
		) b LEFT JOIN quorum_range_partitioned_jul10_hist_min_max_date c 
		ON 
			b.pv_wc_id::numeric = c.refid_out::numeric
		LEFT JOIN calendar_minmax d
			ON b.pv_wc_id::numeric = d.refid::numeric;	

END;
$$ LANGUAGE plpgsql;
