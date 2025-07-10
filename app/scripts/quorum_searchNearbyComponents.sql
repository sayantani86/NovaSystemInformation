DROP FUNCTION fetchNearbyComponents(refid_arr numeric[]);

CREATE OR REPLACE FUNCTION fetchNearbyComponents(refid_arr numeric[]) RETURNS TABLE (wellname varchar, refid numeric, pipelines text[]) AS 
$$
DECLARE
	r numeric;
BEGIN
	RAISE NOTICE 'RefIDs = %', refid_arr;

	FOREACH r IN ARRAY refid_arr LOOP
		RAISE NOTICE 'r = %', r;
		
		RETURN QUERY SELECT
	       		p.wellname,	
			p.refid, 
			string_to_array(p.items, '|') as pipelines 
		FROM 
			maps.nearby_pipelines p 
		WHERE
			p.refid::numeric = r::numeric;
	END LOOP;
	
	RETURN;
 END;
$$ LANGUAGE plpgsql;

