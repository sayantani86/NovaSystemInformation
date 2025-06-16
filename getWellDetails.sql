DROP FUNCTION getWellDetails(refid text);

CREATE OR REPLACE FUNCTION getWellDetails(refid text) 
 RETURNS TABLE (
	w_description varchar,
	w_county varchar,
	w_state varchar,
	w_pv_wc_id numeric,
	w_mth_1st_activity varchar,
	quorum_firstproductiondate varchar,
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
	RAISE NOTICE 'RefId = %', quote_literal(refid);

	RETURN QUERY SELECT description,
		county, 
		state, 
		pv_wc_id::numeric,
	       	mth_1st_activity,
		firstproductiondate,
		shl_x, 
		shl_y,
		longitude::varchar,
		latitude::varchar,
		foreman, 
		gl1, 
		"GL1 Range"::varchar, 
		gl2, 
		"GL2 Range"::varchar 
	FROM maps.wells_merged_by_name a
	WHERE a.pv_wc_id::numeric =getWellDetails.refid::numeric;

END;
$$ LANGUAGE plpgsql;
