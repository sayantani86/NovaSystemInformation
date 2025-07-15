DROP FUNCTION fetchNearbyComponents(refid_arr numeric[]);

--DROP FUNCTION fetchNearbyComponents(req jsonb);

CREATE OR REPLACE FUNCTION fetchNearbyComponents(req jsonb) RETURNS TABLE (refid numeric, pipelines text[]) AS 
$$
DECLARE
	r numeric;
BEGIN
	RAISE NOTICE '%', req;

	FOREACH r IN ARRAY refid_arr LOOP
		RAISE NOTICE 'r = %', r;
		

		RETURN QUERY 
		SELECT
			p.refid, 
			string_to_array(all_pipelines, '|') as pipelines 
		FROM 
			(
				SELECT t.refid, string_agg(sys_subsys_nm, '|') as all_pipelines FROM (
					select DISTINCT tab.refid, sys_subsys_nm from maps.pipelines_in_2_miles_ungrouped tab order by tab.refid
				) t 
				GROUP BY t.refid
			) p
		WHERE
			p.refid::numeric = r::numeric;
	END LOOP;
	
	RETURN;
 END;
$$ LANGUAGE plpgsql;

