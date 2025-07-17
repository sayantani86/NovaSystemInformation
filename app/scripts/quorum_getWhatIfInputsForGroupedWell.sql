DROP FUNCTION getWhatIfInputsForGroupedWells_1(jsonb);

CREATE OR REPLACE FUNCTION getWhatIfInputsForGroupedWells_1(req jsonb) RETURNS TABLE (
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
        q_wltype_encoded float,
        q_shutin_flag3 float,
        q_allocatedproductionoilvolume_lag1 numeric(13, 2),
        q_allocatedproductionoilvolume numeric(13, 2)
) AS
$$
DECLARE
	r record;
	well numeric;

BEGIN
	RAISE NOTICE '%', req;

	FOR r IN SELECT * FROM jsonb_array_elements(req -> 'productionWellList')
	LOOP
		RETURN QUERY SELECT * FROM getRangedDataFromQuorumByWell(r::text, (regexp_replace(r::text, '\.01', '01'))::integer, req ->> 'startDate', req -> 'endDate'::date);
	END LOOP;
	
	RETURN;
END;
$$ LANGUAGE plpgsql;
