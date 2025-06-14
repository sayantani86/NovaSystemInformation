DROP FUNCTION getRangedDataFromQuorumByWell(wellname text, start_date text, end_date text);


CREATE OR REPLACE FUNCTION getRangedDataFromQuorumByWell(wellname text, st_dt text, et_dt text) RETURNS SETOF quorum_range_partitioned AS
$$
DECLARE
        fnc_cmd text;
        wellname_nowhitespace text := regexp_replace(regexp_replace(regexp_replace(wellname, '#', ''), '-', ''), '\s+', '', 1, 0, 'i');
BEGIN
        RAISE NOTICE 'wellname = % and % and % and %', quote_literal(wellname), quote_literal(wellname_nowhitespace), quote_literal(st_dt), quote_literal(et_dt);

	fnc_cmd := 'SELECT * FROM quorum_range_partitioned  WHERE regexp_replace(regexp_replace(regexp_replace((regexp_match(wellname, ''(.*\dH).*''))[1], ''#'', ''''), ''-'', ''''), ''\s+'', '''', 1, 0, ''i'') = ' || quote_literal(wellname_nowhitespace) || ' and entry_date::date >=' || quote_literal(st_dt) || ' and entry_date::date < ' || quote_literal(et_dt);

        RAISE NOTICE 'SQL = %', fnc_cmd;

        RETURN QUERY EXECUTE fnc_cmd;

END;
$$ LANGUAGE plpgsql;
