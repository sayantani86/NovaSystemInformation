DROP FUNCTION getWellDetails(wellname text);

CREATE OR REPLACE FUNCTION getWellDetails(wellname text) RETURNS SETOF maps.quorum_wells AS
$$
DECLARE
        wellname_nowhitespace text := regexp_replace(regexp_replace(regexp_replace(wellname, '#', ''), '-', ''), '\s+', '', 1, 0, 'i');
        r record;
BEGIN
	RAISE NOTICE 'wellname = % and %', quote_literal(wellname), quote_literal(wellname_nowhitespace);

	SELECT name INTO r FROM iron_iq_well_name_to_accounting_id_table WHERE regexp_replace(regexp_replace(regexp_replace(name, '#', ''), '-', ''), '\s+', '', 1, 0, 'i') = wellname_nowhitespace;

        IF r IS NULL THEN
            RAISE EXCEPTION 'Nonexistent well --> %', wellname;
        ELSE
            RAISE NOTICE 'Matched name is % for %', r.name, wellname;
        END IF;

	RETURN QUERY SELECT a.* FROM maps.quorum_wells a WHERE regexp_replace(regexp_replace(regexp_replace(a.wellname, '#', ''), '-', ''), '\s+', '', 1, 0, 'i') = wellname_nowhitespace;

END;
$$ LANGUAGE plpgsql;
