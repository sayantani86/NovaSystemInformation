-- Create the part lookup table

DROP TABLE ironiq_lookup_weekly;

CREATE TABLE ironiq_lookup_weekly(
        part_file_name text NOT NULL,
	file_size integer,
        start_date date,
        end_date date,
        part_table_name varchar(100),
        range_start date,
        range_end date,
        created_dt timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
        created_by varchar NOT NULL DEFAULT CURRENT_USER
);

--GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public to ironiq_read_write;
