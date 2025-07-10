DROP FUNCTION getWhatIfInputsForGroupedWells();

CREATE OR REPLACE FUNCTION getWhatIfInputsForGroupedWells() RETURNS TABLE (
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
        q_wl_type varchar,
        q_shutin_flag1 integer,
        q_shutin_flag3 float,
        q_rampup_flag boolean,
        q_allocatedproductionoilvolume numeric(13, 2),
        q_allocatedproductionoilvolume_lag1 numeric(13, 2),
        q_allocatedproductionoilvolume_lag2 numeric(13, 2),
        q_allocatedproductionoilvolume_lag3 numeric(13, 2),
        q_wltype_encoded float
) AS
$$
DECLARE
        fnc_cmd text;
	r record;
BEGIN
	FOR r in SELECT * from quorum_whatif.whatif_inputs
	LOOP
		RETURN QUERY SELECT * FROM getRangedDataFromQuorumByWell(r.refid::text, (regexp_replace(r.refid::text, '\.01', '01'))::integer, r.start_date, r.end_date);
	END LOOP;
	RETURN;
END;
$$ LANGUAGE plpgsql;
