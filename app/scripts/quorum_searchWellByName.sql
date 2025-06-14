DROP FUNCTION searchWellInQuorum(well_name text);

CREATE OR REPLACE FUNCTION searchWellInQuorum(wellname text) RETURNS TABLE (well_name varchar) AS
$$
DECLARE
        wellname_nowhitespace text := regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(
            regexp_replace(
                regexp_replace(
                    regexp_replace(
                        regexp_replace(
                                regexp_replace(regexp_replace(regexp_replace((regexp_match(wellname, '(.*[0-9][0-9]*H).*'))[1], 'NO\W', '', 1, 0, 'i'), 'SA', ''), '^NO', '', 1, 0, 'i'),
                        'HUNTER', '', 1, 0, 'i'),
                    '[#|-|,|.|\W+]', '', 1, 0, 'i'),
                '\s{1,}', '', 1, 0, 'i'),
            'UNIT', '', 1, 0, 'i'),
        'LTD', 'LIMITED', 1, 0, 'i'),'RCRJANE', 'RCRSJANE'), 'McCREARY', 'MCCREARY', 1, 0, 'i'), '^JAKEBERGERCC', 'JAKEBERGERJRCATTLECOMPANY'),'BERCKENHOFFA', 'BERCKENHOFF');
        
	r record;
BEGIN
        RAISE NOTICE 'wellname = % and wellname_nowhitespace = %', quote_literal(wellname), quote_literal(wellname_nowhitespace);

        SELECT qw.description as "Well Name", geometry, longitude INTO r FROM maps.wells_merged_by_name qw WHERE regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(
            regexp_replace(
                regexp_replace(
                    regexp_replace(
                        regexp_replace(
                                regexp_replace(regexp_replace(regexp_replace((regexp_match(qw.description, '(.*[0-9][0-9]*H).*'))[1], 'NO\W', '', 1, 0, 'i'), 'SA', ''), '^NO', '', 1, 0, 'i'),
                        'HUNTER', '', 1, 0, 'i'),
                    '[#|-|,|.|\W+]', '', 1, 0, 'i'),
                '\s{1,}', '', 1, 0, 'i'),
            'UNIT', '', 1, 0, 'i'),
        'LTD', 'LIMITED', 1, 0, 'i'),'RCRJANE', 'RCRSJANE'), 'McCREARY', 'MCCREARY', 1, 0, 'i'), '^JAKEBERGERCC', 'JAKEBERGERJRCATTLECOMPANY'),'BERCKENHOFFA', 'BERCKENHOFF')  = wellname_nowhitespace;

	RAISE NOTICE 'r = %', r;

	IF r IS NULL THEN
		RAISE EXCEPTION 'Nonexistent well --> %', wellname;
	END IF;

	IF r.geometry IS NULL THEN
		RAISE EXCEPTION '% is missing coordinates', wellname;
        END IF;

	RETURN QUERY
		SELECT qw.description as "Well Name" FROM maps.wells_merged_by_name qw WHERE regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(
            regexp_replace(
                regexp_replace(
                    regexp_replace(
                        regexp_replace(
                                regexp_replace(regexp_replace(regexp_replace((regexp_match(qw.description, '(.*[0-9][0-9]*H).*'))[1], 'NO\W', '', 1, 0, 'i'), 'SA', ''), '^NO', '', 1, 0, 'i'),
                        'HUNTER', '', 1, 0, 'i'),
                    '[#|-|,|.|\W+]', '', 1, 0, 'i'),
                '\s{1,}', '', 1, 0, 'i'),
            'UNIT', '', 1, 0, 'i'),
        'LTD', 'LIMITED', 1, 0, 'i'),'RCRJANE', 'RCRSJANE'), 'McCREARY', 'MCCREARY', 1, 0, 'i'), '^JAKEBERGERCC', 'JAKEBERGERJRCATTLECOMPANY'),'BERCKENHOFFA', 'BERCKENHOFF')  = wellname_nowhitespace;

END;
$$ LANGUAGE plpgsql;
