
DROP FUNCTION getRangedDataFromIronIQByWell(wellname text, start_date text, end_date text);

CREATE OR REPLACE FUNCTION getRangedDataFromIronIQByWell(wellname text, st_dt text, et_dt text) RETURNS SETOF ironiq_weekly_partitioned AS 
$$
DECLARE
	r RECORD;
	fnc_cmd text;
	wellname_nowhitespace text := array_to_string(regexp_split_to_array(regexp_replace(regexp_replace(wellname, '#', ''), '-', ''), '\s+'), '');
BEGIN
	RAISE NOTICE 'wellname = % and % and % and %', quote_literal(wellname), quote_literal(wellname_nowhitespace), quote_literal(st_dt), quote_literal(et_dt);
	
	FOR r in select DISTINCT(part_table_name)  FROM ironiq_lookup_weekly where range_start >= st_dt::date and range_start < (et_dt::date + 1)
		LOOP

		RAISE NOTICE 'part_name = %', r.part_table_name; 
               
		fnc_cmd := 'SELECT * FROM part_ironiq.' || quote_ident(r.part_table_name) || ' WHERE id::int IN (select item_id::int from iqranger_equipment_lookup WHERE array_to_string(regexp_split_to_array(regexp_replace(regexp_replace((regexp_match(equipment, ''(.*\dH).*''))[1], ''#'', ''''), ''-'', ''''), ''\s+''), '''') = ' || quote_literal(wellname_nowhitespace) || ') and timestamp::date >=' || quote_literal(st_dt) || ' and timestamp::date <=' || quote_literal(et_dt);

		--RAISE NOTICE 'SQL = %', fnc_cmd;

		RETURN QUERY EXECUTE fnc_cmd;
		
	END LOOP;
	RETURN;
END;
$$ LANGUAGE plpgsql;



