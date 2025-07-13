DROP FUNCTION fetchNearbyComponentsNew(jsonb);

CREATE OR REPLACE FUNCTION fetchNearbyComponentsNew(req jsonb) RETURNS TABLE (refid numeric, pipelines text[]) AS 
$$
DECLARE
	r numeric;
BEGIN
	RAISE NOTICE '% %', req, req -> 'productionWellList' -> 0;

	FOR r IN SELECT * FROM jsonb_array_elements(req -> 'productionWellList') LOOP
		RAISE NOTICE 'r = %', r;
		

		RETURN QUERY SELECT p.refid, string_to_array(string_agg, '|') as pipelines  FROM maps.pipelines_in_2_miles p WHERE p.refid::numeric = r::numeric;

	END LOOP;
	
	RETURN;
 END;
$$ LANGUAGE plpgsql;

