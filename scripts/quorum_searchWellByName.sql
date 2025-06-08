DROP FUNCTION searchWellInQuorum(wellname text);

CREATE OR REPLACE FUNCTION searchWellInQuorum(wellname text) RETURNS void AS
$$
DECLARE
        wellname_nowhitespace text := regexp_replace(regexp_replace(regexp_replace(wellname, '#', ''), '-', ''), '\s+', '', 1, 0, 'i');
        r record;
BEGIN
        RAISE NOTICE 'wellname = % and wellname_nowhitespace = %', quote_literal(wellname), quote_literal(wellname_nowhitespace);

        SELECT qw.wellname INTO r FROM maps.quorum_wells qw WHERE regexp_replace(regexp_replace(regexp_replace(qw.wellname, '#', ''), '-', ''), '\s+', '', 1, 0, 'i') = wellname_nowhitespace;

        IF r IS NULL THEN
            RAISE EXCEPTION 'Nonexistent well --> %', wellname;
        ELSE
            RAISE NOTICE 'Matched name is % for %', r.wellname, wellname;
        END IF;

END;
$$ LANGUAGE plpgsql;
