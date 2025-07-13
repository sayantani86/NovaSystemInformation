DROP FUNCTION getRangedDataFromQuorumByWell(text, integer, text, text);

CREATE OR REPLACE FUNCTION getRangedDataFromQuorumByWell(refid text, refid_num integer, st_dt text, et_dt text) RETURNS TABLE (
	q_wellname varchar,
	q_refid float,
	q_entry_date date,
	q_sequential_month integer,
	q_sequential_day integer,
	q_linepressure numeric(8,2),
	q_casingpressure numeric(8,2),
	q_flowingtubingpressure numeric(8,2),
	q_allocatedgasinjectionvolume numeric(13,2),
	q_choke float,
	q_welllift_flag boolean,
	q_wl_type varchar,
	q_shutin_flag1 integer,
	q_shutin_flag3 float,
	q_rampup_flag boolean,
	q_allocatedproductionoilvolume numeric(13, 2),
        q_allocatedproductionoilvolume_lag1 numeric(13, 2),
        q_allocatedproductionoilvolume_lag2 numeric(13, 2),
        q_allocatedproductionoilvolume_lag3 numeric(13, 2),
        q_wltype_encoded float,
	hist_min_date date,
	hist_max_date date,
	cal_min_date date,
	cal_max_date date
) AS
$$
DECLARE
        fnc_cmd text;

	r record;
BEGIN
        RAISE NOTICE 'Processing RefID = % from % to %', quote_literal(refid), quote_literal(st_dt), quote_literal(et_dt);


	SELECT a.* FROM
		(
			SELECT description, description_nowhitespace, pv_wc_id as ref_id, well_name, wellname, geometry, longitude::float, latitude::float FROM maps.wells_in_3_datasources UNION
                        SELECT description, description_nowhitespace, pv_wc_id as ref_id, well_name, wellname, geometry, longitude::float, latitude::float FROM maps.master_wells_in_quorum_only UNION
                        SELECT description, description_nowhitespace, pv_wc_id as ref_id, well_name, wellname, geometry, longitude::float, latitude::float FROM maps.master_wells_unmatched_with_baytex UNION
                        SELECT description, description_nowhitespace, pv_wc_id as ref_id, well_name, wellname, geometry, longitude::float, latitude::float FROM maps.master_wells_with_geom_only UNION
                        SELECT description, description_nowhitespace, pv_wc_id as ref_id, well_name, wellname, geometry, longitude::float, latitude::float FROM maps.others
		) 
	a INTO r  WHERE ref_id::numeric = getRangedDataFromQuorumByWell.refid::numeric;

	IF r.well_name IS NULL AND r.wellname IS NULL THEN
                RAISE EXCEPTION '% is missing coordinates', r.description;
        END IF;

	fnc_cmd := 'SELECT 
		wellname,
		prod.refid,
		entry_date,
		sequential_month,
		sequential_day,
		linepressure,
		casingpressure,
		flowingtubingpressure,
		allocatedgasinjectionvolume,
		choke,
		welllift_flag::boolean,
		wl_type,
		shutin_flag1,
		shutin_flag3,
		rampup_flag::boolean,
		allocatedproductionoilvolume,
		allocatedproductionoilvolume_lag1,
		allocatedproductionoilvolume_lag2,
		allocatedproductionoilvolume_lag3,
		wltype_encoded,
		c.min_entry_date,
		c.max_entry_date, 
		d.calendar_min, 
		d.calendar_max
       	FROM 
		quorum_range_partitioned_jul10 prod
	LEFT JOIN 
		quorum_range_partitioned_jul10_hist_min_max_date c
        ON
        	prod.refid::numeric = c.refid_out::numeric
        LEFT JOIN 
		calendar_minmax d
        ON 
		prod.refid::numeric = d.refid::numeric	
        WHERE
		prod.refid::numeric = ' || getRangedDataFromQuorumByWell.refid::numeric || ' and entry_date::date >=' || quote_literal(st_dt) || ' and entry_date::date <= ' || quote_literal(et_dt);

        RETURN QUERY EXECUTE fnc_cmd;

END;
$$ LANGUAGE plpgsql;
