DROP FUNCTION getRangedDataFromQuorumByWell(refid text, refid_num integer, start_date text, end_date text);

CREATE OR REPLACE FUNCTION getRangedDataFromQuorumByWell(refid text, refid_num integer, st_dt text, et_dt text) RETURNS TABLE (
	q_wellname varchar,
	q_entry_date date,
	q_flowingtubingpressure numeric(8,2),
	q_casingpressure numeric(8,2),
	q_linepressure numeric(8,2),
	q_allocatedgasinjectionvolume numeric(13,2),
	q_choke float,
	q_allocatedproductionoilvolume numeric(13,2),
	q_gasliftgasmeasuredvolume numeric(13,2),
	q_gaslift_flag float,
	q_rampup_flag float,
	q_shutin_flag1 float,
	q_shutin_flag2 float,
	q_sequential_month float
) AS
$$
DECLARE
        fnc_cmd text;

	r record;
BEGIN
        RAISE NOTICE 'Wellname = % from % to %', quote_literal(refid), quote_literal(st_dt), quote_literal(et_dt);

	SELECT qw.description as "Well Name", description_nowhitespace, pv_wc_id  INTO r FROM maps.wells_merged_by_name qw WHERE pv_wc_id::numeric = getRangedDataFromQuorumByWell.refid::numeric;

	fnc_cmd := 'SELECT well_name,
		entry_date,
		flowingtubingpressure,
		casingpressure,
		linepressure,
		allocatedgasinjectionvolume,
		choke,
		allocatedproductionoilvolume,
		gasliftgasmeasuredvolume,
		gaslift_flag,
		rampup_flag,
		shutin_flag1,
		shutin_flag2,
		sequential_month
       	FROM quorum_range_partitioned 
        WHERE regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(
              regexp_replace(regexp_replace(
                                                                				regexp_replace(
                                                                        				regexp_replace(
                                                                                				regexp_replace(
                                                                                        				regexp_replace(
                                                                regexp_replace(
										regexp_replace(
											(regexp_match(well_name, ''(.*[0-9]{1,}H).*''))[1], ''WAVELITE'', ''WAVELLITE'')
										, ''SA'', ''''),
                                                            ''NO\W'', '''', 1, 0, ''i''), ''^NO'', '''', 1, 0, ''i''),
                                                        ''HUNTER'', '''', 1, 0, ''i''),
                                                    ''[#|-|,|.|\W+]'', '''', 1, 0, ''i''),
                                                ''\s{1,}'', '''', 1, 0, ''i''),
                                            ''UNIT'', '''', 1, 0, ''i''),
                                        ''LTD'', ''LIMITED'', 1, 0, ''i''),
                                ''^JAKEBERGERCC'', ''JAKEBERGERJRCATTLECOMPANY''), ''SHINERRANCHSOUTHERN'', ''SHINERRANCHS'', 1, 0, ''i''), ''WASHINGTONR'', ''RWASHINGTON''), ''SCHAEFERRL'', ''RLSCHAEFER''), ''McCREARY'', ''MCCREARY'', 1, 0, ''i''),''^LEELJ'', ''LJLEE''), ''SIMPERJOSEPH'', ''JOSEPHSIMPER''), ''^BERGERJ'', ''JBERGER''), ''FOREMAND'', ''DFOREMAN''), ''BERCKENHOFFA'',''BERCKENHOFF'') = ' || quote_literal(r.description_nowhitespace) || ' and entry_date::date >=' || quote_literal(st_dt) || ' and entry_date::date < ' || quote_literal(et_dt);

	EXECUTE 'DROP TABLE IF EXISTS quorum_whatif.' || 'w_' || refid_num;

	EXECUTE 'CREATE TABLE quorum_whatif.' || 'w_' || refid_num || ' AS (' || fnc_cmd || ')';

        RETURN QUERY EXECUTE 'SELECT * FROM quorum_whatif.' || 'w_' || refid_num;

END;
$$ LANGUAGE plpgsql;
