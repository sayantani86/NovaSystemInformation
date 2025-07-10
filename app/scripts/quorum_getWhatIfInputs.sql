DROP FUNCTION getRangedDataFromQuorumByWell(refid text, refid_num integer, start_date text, end_date text);

CREATE OR REPLACE FUNCTION getRangedDataFromQuorumByWell(refid text, refid_num integer, st_dt text, et_dt text) RETURNS TABLE (
	q_well_name varchar,
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
	q_shutin_flag boolean,
	q_rampup_flag boolean,
	q_allocatedproductionoilvolume numeric(13, 2),
        q_allocatedproductionoilvolume_lag1 numeric(13, 2),
        q_allocatedproductionoilvolume_lag2 numeric(13, 2),
        q_allocatedproductionoilvolume_lag3 numeric(13, 2),
        q_wltype_encoded integer
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
		wellname as well_name,
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
		shutin_flag::boolean,
		rampup_flag::boolean,
		allocatedproductionoilvolume,
		allocatedproductionoilvolume_lag1,
		allocatedproductionoilvolume_lag2,
		allocatedproductionoilvolume_lag3,
		wltype_encoded
       	FROM 
		quorum_range_partitioned_jul9 
        WHERE
		(regexp_match(
                regexp_replace(
                regexp_replace(
                regexp_replace(
                regexp_replace(
                regexp_replace(
                regexp_replace(
                regexp_replace(
                regexp_replace(
                regexp_replace(
                regexp_replace(
                regexp_replace(
                        regexp_replace(wellname, ''(DUBOSE UNIT)(.*\yNO\y)(.*)'', ''\1\3'', 1, 0),
                ''(DUBOSE UNIT.*)(WELL)(.*)'', ''\1\3''),
                ''(EBONY).*([0-9]H)'', ''\1\2''),
                ''\(SA\)'', '''', 1, 0),
                ''HUNTER'', '''', 1, 0, ''i''),
                ''[#|-|,|.|\W+]'', '''', 1, 0, ''i''),
                ''UNIT'', '''', 1, 0, ''i''),
                ''LTD'', ''LIMITED'', 1, 0, ''i''),
                ''\yJAKEBERGERCC\y'', ''JAKEBERGERJRCATTLECOMPANY''),
                ''RCRJANE'', ''RCRSJANE''),
                ''McCREARY'', ''MCCREARY'',1, 0,''i''),
                ''(BERCKENHOFF)A'', ''\1''),
        ''(.*[0-9]{1,}\s*H).*''))[1] = ' || quote_literal(r.description_nowhitespace) || ' and entry_date::date >=' || quote_literal(st_dt) || ' and entry_date::date <= ' || quote_literal(et_dt);


        RETURN QUERY EXECUTE fnc_cmd;

END;
$$ LANGUAGE plpgsql;
