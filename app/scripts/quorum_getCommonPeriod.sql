DROP FUNCTION get_multiwells_overlapping_period(jsonb);

CREATE OR REPLACE FUNCTION get_multiwells_overlapping_period(req jsonb) RETURNS TABLE (refid numeric, min_date date, max_date date) AS
$$
DECLARE
	r numeric;

BEGIN

	FOR r in SELECT * FROM jsonb_array_elements(req -> 'productionWellList')
	LOOP
		RAISE NOTICE '%', r;

		RETURN QUERY SELECT refid_out::numeric, min_entry_date, max_entry_date from quorum_range_partitioned_jul10_hist_min_max_date WHERE refid_out::numeric = r::numeric; 
	END LOOP;

	--RETURN QUERY EXECUTE 'SELECT * FROM quorum_range_partitioned_jul10_hist_min_max_date WHERE refid_out IN ' || productionWellList || ')';
END;
$$ LANGUAGE plpgsql;

--SELECT * FROM get_multiwells_overlapping_period('{"productionWellList": [203230.01, 203334.01]}'::jsonb);
