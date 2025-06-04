DROP FUNCTION searchWellInIronIQ(wellname text);

CREATE OR REPLACE FUNCTION searchWellInIronIQ(wellname text) RETURNS TABLE (f1 text) AS
$$
DECLARE
        wellname_nowhitespace text := array_to_string(regexp_split_to_array(regexp_replace(regexp_replace(wellname, '#', ''), '-', ''), '\s+'), '');
        found_well text := NULL;
BEGIN
        RAISE NOTICE 'wellname = % and %', quote_literal(wellname), quote_literal(wellname_nowhitespace);

        SELECT name INTO found_well FROM iron_iq_well_name_to_accounting_id_table WHERE array_to_string(regexp_split_to_array(regexp_replace(regexp_replace(name, '#', ''), '-', ''), '\s+'), '') = wellname_nowhitespace;

        IF found_well IS NULL THEN
            RAISE EXCEPTION 'Nonexistent well --> %', wellname;
        ELSE
                RAISE NOTICE 'Well found = %', found_well;
        END IF;

        RETURN QUERY 
		SELECT DISTINCT TRIM(equipment) as equipment FROM iqranger_equipment_lookup WHERE array_to_string(regexp_split_to_array(regexp_replace(regexp_replace((regexp_match(equipment, '(.*\dH).*'))[1], '#', ''), '-', ''), '\s+'), '') = wellname_nowhitespace;


        --IF r IS NULL THEN
        --      RAISE EXCEPTION 'Well name % does not match with IronIQ', wellname;
       -- END IF;

END;
$$ LANGUAGE plpgsql;
