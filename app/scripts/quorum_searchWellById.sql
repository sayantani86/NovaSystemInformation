DROP FUNCTION searchWellById(refid text);

CREATE OR REPLACE FUNCTION searchWellById(refid text) RETURNS TABLE (well_name varchar, well_name_nowhitespace text) AS
$$
DECLARE
        r record;
BEGIN
        SELECT qw.description as "Well Name", description_nowhitespace, geometry, longitude INTO r FROM maps.wells_merged_by_name qw WHERE pv_wc_id::numeric = searchWellById.refid::numeric;

        RAISE NOTICE 'r = %', r;

        IF r IS NULL THEN
                RAISE EXCEPTION 'Nonexistent well --> %', r."Well Name";
        END IF;

        IF r.geometry IS NULL THEN
                RAISE EXCEPTION '% is missing coordinates', r."Well Name";
        END IF;

	RETURN QUERY
                SELECT qw.description as well_name, description_nowhitespace  FROM maps.wells_merged_by_name qw WHERE pv_wc_id::numeric = searchWellById.refid::numeric; 

END;
$$ LANGUAGE plpgsql;
