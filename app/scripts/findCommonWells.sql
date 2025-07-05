DROP TABLE maps.wells_merged_by_name;

CREATE TABLE maps.wells_merged_by_name AS (
    select w1.description,
	w1.pv_wc_id,
	w1.lavaca_number AS "Lavaca Number",
	w1.mth_1st_activity,
	w1.county AS County,
	w1.state AS State,
	w3.firstproductiondate,
    	w2.well_name,
	w2.enertia_id,
    	w2.shl_x,
    	w2.shl_y,
	w2.geometry,
	w3.wellname,
	w3.refid,
	w3.formation,
	w3.longitude,
	w3.latitude,
	w3.foreman,
	w3.wl_type2 AS gl1,
	CASE 
		WHEN wl2_begindt = 'NULL' THEN NULL
		ELSE 
			date_part('year', wl2_begindt::date)::text || '-' || date_part('month', wl2_begindt::date)::text || '-' || date_part('day', wl2_begindt::date)::text || ' to ' ||
			date_part('year', wl2_enddt::date)::text || '-' || date_part('month', wl2_enddt::date)::text || '-' || date_part('day', wl2_enddt::date)::text
	END AS "GL1 Range",
	w3.wl_type1 AS gl2,
	CASE
		WHEN wl1_begindt = 'NULL' THEN NULL
		ELSE
        		date_part('year', wl1_begindt::date)::text || '-' || date_part('month', wl1_begindt::date)::text || '-' || date_part('day', wl1_begindt::date)::text || ' to ' ||
        		date_part('year', wl1_enddt::date)::text || '-' || date_part('month', wl1_enddt::date)::text || '-' || date_part('day', wl1_enddt::date)::text
	END AS "GL2 Range",
        regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(
            regexp_replace(
                regexp_replace(
                    regexp_replace(
                        regexp_replace(
				regexp_replace(regexp_replace(regexp_replace((regexp_match(w1.description, '(.*[0-9]{1,}H).*'))[1], 'NO\W', '', 1, 0, 'i'), 'SA', ''), '^NO', '', 1, 0, 'i'), 
                        'HUNTER', '', 1, 0, 'i'), 
                    '[#|-|,|.|\W+]', '', 1, 0, 'i'),
                '\s{1,}', '', 1, 0, 'i'), 
            'UNIT', '', 1, 0, 'i'), 
        'LTD', 'LIMITED', 1, 0, 'i'),'RCRJANE', 'RCRSJANE'), 'McCREARY', 'MCCREARY', 1, 0, 'i'), '^JAKEBERGERCC', 'JAKEBERGERJRCATTLECOMPANY'),'BERCKENHOFFA', 'BERCKENHOFF')
 AS description_nowhitespace, 
        regexp_replace(regexp_replace(
            regexp_replace(
                regexp_replace(
                        regexp_replace(
                                regexp_replace(
                                        regexp_replace(
                                                regexp_replace(
                                                        regexp_replace(
                                                                regexp_replace(
                                                                        regexp_replace(
                                                                            regexp_replace(
                                                                                regexp_replace(
                                                                                        regexp_replace(
                                                                                            regexp_replace(regexp_replace(regexp_replace(regexp_replace((regexp_match(w2.well_name, '(.*[0-9]{1,}H).*'))[1], 'WAVELITE', 'WAVELLITE'),'SA', ''),'NO\W', '', 1, 0, 'i'), '^NO', '', 1, 0, 'i'),
                                                                                'HUNTER', '', 1, 0, 'i'),
                                                                        '[#|-|,|.|\W+]', '', 1, 0, 'i'),
                                                                '\s{1,}', '', 1, 0, 'i'),
                                                        'UNIT', '', 1, 0, 'i'),
                                                'LTD', 'LIMITED', 1, 0, 'i'), 
                                        'SHINERRANCHSOUTHERN', 'SHINERRANCHS'), 
                                'WASHINGTONR', 'RWASHINGTON'), 
                            'SCHAEFERRL', 'RLSCHAEFER'), 
                        'McCREARY', 'MCCREARY', 1, 0, 'i'), 
                    'LEELJ', 'LJLEE'), 
                'SIMPERJOSEPH', 'JOSEPHSIMPER'), 
            '^BERGERJ', 'JBERGER'), 
        '^JAKEBERGERCC', 'JAKEBERGERJRCATTLECOMPANY'),'BERCKENHOFFA', 'BERCKENHOFF') AS "Well_Name_nowhitespace",
regexp_replace(regexp_replace(regexp_replace(regexp_replace(
                regexp_replace(
                    regexp_replace(
                        regexp_replace(
                            regexp_replace(
                                regexp_replace(
                                    regexp_replace(regexp_replace(regexp_replace((regexp_match(w3.wellname, '(.*[0-9]{1,}H).*'))[1], 'NO\W', '', 1, 0, 'i'), 'SA', ''), '^NO', '', 1, 0, 'i'),
                                'HUNTER', '', 1, 0, 'i'),
                            '[#|-|,|.|\W+]', '', 1, 0, 'i'),
                         '\s{1,}', '', 1, 0, 'i'),
                    'UNIT', '', 1, 0, 'i'),
                 'LTD', 'LIMITED', 1, 0, 'i'), '^JAKEBERGERCC', 'JAKEBERGERJRCATTLECOMPANY'), 'RCRJANE', 'RCRSJANE'), 'McCREARY', 'MCCREARY', 1, 0, 'i') ,'BERCKENHOFFA', 'BERCKENHOFF') AS quorum_well_nowhitespace
FROM 
    master_list_of_baytex_wells w1 LEFT JOIN maps.baytex_wells w2 
ON 
           regexp_replace(regexp_replace(regexp_replace(regexp_replace(
                regexp_replace(
                    regexp_replace(
                        regexp_replace(
                            regexp_replace(
                                regexp_replace(
                                    regexp_replace(regexp_replace(regexp_replace((regexp_match(w1.description, '(.*[0-9]{1,}H).*'))[1], 'NO\W', '', 1, 0, 'i'), 'SA', ''), '^NO', '', 1, 0, 'i'),
			       	'HUNTER', '', 1, 0, 'i'), 
                            '[#|-|,|.|\W+]', '', 1, 0, 'i'), 
                         '\s{1,}', '', 1, 0, 'i'), 
                    'UNIT', '', 1, 0, 'i'), 
                 'LTD', 'LIMITED', 1, 0, 'i'), '^JAKEBERGERCC', 'JAKEBERGERJRCATTLECOMPANY'), 'RCRJANE', 'RCRSJANE'), 'McCREARY', 'MCCREARY', 1, 0, 'i'),
'BERCKENHOFFA', 'BERCKENHOFF') 
                                = regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(
					regexp_replace(
						regexp_replace(
							regexp_replace(
								regexp_replace(
									regexp_replace(
									       	regexp_replace(
											regexp_replace(regexp_replace(
                                                                	regexp_replace(regexp_replace((regexp_match(w2.well_name, '(.*[0-9]{1,}H).*'))[1], 'WAVELITE', 'WAVELLITE'), 'SA', ''), 
                                                            'NO\W', '', 1, 0, 'i'), '^NO', '', 1, 0, 'i'), 
                                                        'HUNTER', '', 1, 0, 'i'), 
                                                    '[#|-|,|.|\W+]', '', 1, 0, 'i'), 
                                                '\s{1,}', '', 1, 0, 'i'), 
                                            'UNIT', '', 1, 0, 'i'), 
                                        'LTD', 'LIMITED', 1, 0, 'i'), 
                                '^JAKEBERGERCC', 'JAKEBERGERJRCATTLECOMPANY'), 'SHINERRANCHSOUTHERN', 'SHINERRANCHS', 1, 0, 'i'), 'WASHINGTONR', 'RWASHINGTON'), 'SCHAEFERRL', 'RLSCHAEFER'), 'McCREARY', 'MCCREARY', 1, 0, 'i'), '^LEELJ', 'LJLEE'), 'SIMPERJOSEPH', 'JOSEPHSIMPER'), '^BERGERJ', 'JBERGER'), 'FOREMAND', 'DFOREMAN'), 'BERCKENHOFFA', 'BERCKENHOFF') 
LEFT JOIN maps.quorum_wells w3 
ON
		regexp_replace(regexp_replace(regexp_replace(regexp_replace(
                regexp_replace(
                    regexp_replace(
                        regexp_replace(
                            regexp_replace(
                                regexp_replace(
                                    regexp_replace(regexp_replace(regexp_replace((regexp_match(w3.wellname, '(.*[0-9]{1,}H).*'))[1], 'NO\W', '', 1, 0, 'i'), 'SA', ''), '^NO', '', 1, 0, 'i'),
                                'HUNTER', '', 1, 0, 'i'),
                            '[#|-|,|.|\W+]', '', 1, 0, 'i'),
                         '\s{1,}', '', 1, 0, 'i'),
                    'UNIT', '', 1, 0, 'i'),
                 'LTD', 'LIMITED', 1, 0, 'i'), '^JAKEBERGERCC', 'JAKEBERGERJRCATTLECOMPANY'), 'RCRJANE', 'RCRSJANE'), 'McCREARY', 'MCCREARY', 1, 0, 'i'), 'BERCKENHOFFA', 'BERCKENHOFF') = 
	regexp_replace(regexp_replace(regexp_replace(regexp_replace(
                regexp_replace(
                    regexp_replace(
                        regexp_replace(
                            regexp_replace(
                                regexp_replace(
                                    regexp_replace(regexp_replace(regexp_replace((regexp_match(w1.description, '(.*[0-9]{1,}H).*'))[1], 'NO\W', '', 1, 0, 'i'), 'SA', ''), '^NO', '', 1, 0, 'i'),
                                'HUNTER', '', 1, 0, 'i'),
                            '[#|-|,|.|\W+]', '', 1, 0, 'i'),
                         '\s{1,}', '', 1, 0, 'i'),
                    'UNIT', '', 1, 0, 'i'),
                 'LTD', 'LIMITED', 1, 0, 'i'), '^JAKEBERGERCC', 'JAKEBERGERJRCATTLECOMPANY'), 'RCRJANE', 'RCRSJANE'), 'McCREARY', 'MCCREARY', 1, 0, 'i'), 'BERCKENHOFFA','BERCKENHOFF')
); 
