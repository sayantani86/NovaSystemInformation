DROP FUNCTION create_range_partition();

CREATE OR REPLACE FUNCTION create_range_partition() RETURNS void AS 
$$
DECLARE
	r RECORD;
	min_start_date text;
	max_end_date text;
	fnc_cmd text;
BEGIN

	SELECT MIN(start_date)::text FROM ironiq_lookup_weekly INTO min_start_date;

	SELECT MAX(end_date)::text FROM ironiq_lookup_weekly INTO max_end_date;

	FOR r IN SELECT *, 'ironiq_y' || date_part('year', t1.start_date) || 'm' || date_part('month', t1.start_date) || 'w' || extract(WEEK FROM  t1.start_date) AS part_table FROM (
                select
                        g.generate_series::date as start_date,
                        (g.generate_series + '14 day'::interval)::date as end_date
                FROM
                        (SELECT * FROM generate_series(quote_literal(min_start_date)::date, quote_literal(max_end_date)::date, '14 day'::interval)) AS g
                ) t1
        LOOP
		--RAISE NOTICE 'UPDATE ironiq_lookup_weekly SET range_start=%,part_table_name=% WHERE start_date >=% and end_date < %', quote_literal(r.start_date), quote_literal(r.part_table), quote_literal(r.start_date), quote_literal(r.end_date);

		EXECUTE 'UPDATE ironiq_lookup_weekly SET range_start=' || quote_literal(r.start_date) || ',range_end=' || quote_literal(r.end_date) ||',part_table_name=' || quote_literal(r.part_table) || ' where start_date >= ' || quote_literal(r.start_date) || ' and end_date <= ' || quote_literal(r.end_date);
		
	--	RAISE NOTICE 'CREATE TABLE part_ironiq.% PARTITION OF ironiq_weekly_partitioned FOR VALUES FROM (%) TO (%)', quote_ident(r.part_table), quote_literal(r.start_date), quote_literal(r.end_date);

		fnc_cmd := 'CREATE TABLE part_ironiq.' || quote_ident(r.part_table) || ' PARTITION OF ironiq_weekly_partitioned FOR VALUES FROM (' || quote_literal(r.start_date) || ') TO (' || quote_literal(r.end_date) || ')';

                EXECUTE fnc_cmd;

	END LOOP;

END;
$$ LANGUAGE plpgsql;

SELECT * FROM create_range_partition();



