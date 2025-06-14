DROP TABLE maps.wells_merged_by_name;

CREATE TABLE maps.wells_merged_by_name AS (
    select w1.description,
	w1.pv_wc_id,
	w1.mth_1st_activity,
    	w2."Well Name",
    	w2."SHL X",
    	w2."SHL Y",
	w2.geometry,
	w3.wellname,
	w3.refid,
	w3.longitude,
	w3.latitude,
        regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(
            regexp_replace(
                regexp_replace(
                    regexp_replace(
                        regexp_replace(
				regexp_replace(regexp_replace(regexp_replace((regexp_match(w1.description, '(.*[0-9][0-9]*H).*'))[1], 'NO\W', '', 1, 0, 'i'), 'SA', ''), '^NO', '', 1, 0, 'i'), 
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
                                                                                            regexp_replace(regexp_replace(regexp_replace(regexp_replace((regexp_match(w2."Well Name", '(.*[0-9][0-9]*H).*'))[1], 'WAVELITE', 'WAVELLITE'),'SA', ''),'NO\W', '', 1, 0, 'i'), '^NO', '', 1, 0, 'i'),
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
                                    regexp_replace(regexp_replace(regexp_replace((regexp_match(w3.wellname, '(.*[0-9][0-9]*H).*'))[1], 'NO\W', '', 1, 0, 'i'), 'SA', ''), '^NO', '', 1, 0, 'i'),
                                'HUNTER', '', 1, 0, 'i'),
                            '[#|-|,|.|\W+]', '', 1, 0, 'i'),
                         '\s{1,}', '', 1, 0, 'i'),
                    'UNIT', '', 1, 0, 'i'),
                 'LTD', 'LIMITED', 1, 0, 'i'), '^JAKEBERGERCC', 'JAKEBERGERJRCATTLECOMPANY'), 'RCRJANE', 'RCRSJANE'), 'McCREARY', 'MCCREARY', 1, 0, 'i') ,'BERCKENHOFFA', 'BERCKENHOFF') AS quorum_well_nowhitespace
FROM 
    master_list_of_lp_rcpt_lavaca_wells w1 LEFT OUTER JOIN maps.baytex_wells w2 
        ON 
           regexp_replace(regexp_replace(regexp_replace(regexp_replace(
                regexp_replace(
                    regexp_replace(
                        regexp_replace(
                            regexp_replace(
                                regexp_replace(
                                    regexp_replace(regexp_replace(regexp_replace((regexp_match(w1.description, '(.*[0-9][0-9]*H).*'))[1], 'NO\W', '', 1, 0, 'i'), 'SA', ''), '^NO', '', 1, 0, 'i'),
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
                                                                	regexp_replace(regexp_replace((regexp_match(w2."Well Name", '(.*[0-9][0-9]*H).*'))[1], 'WAVELITE', 'WAVELLITE'), 'SA', ''), 
                                                            'NO\W', '', 1, 0, 'i'), '^NO', '', 1, 0, 'i'), 
                                                        'HUNTER', '', 1, 0, 'i'), 
                                                    '[#|-|,|.|\W+]', '', 1, 0, 'i'), 
                                                '\s{1,}', '', 1, 0, 'i'), 
                                            'UNIT', '', 1, 0, 'i'), 
                                        'LTD', 'LIMITED', 1, 0, 'i'), 
                                '^JAKEBERGERCC', 'JAKEBERGERJRCATTLECOMPANY'), 'SHINERRANCHSOUTHERN', 'SHINERRANCHS', 1, 0, 'i'), 'WASHINGTONR', 'RWASHINGTON'), 'SCHAEFERRL', 'RLSCHAEFER'), 'McCREARY', 'MCCREARY', 1, 0, 'i'), '^LEELJ', 'LJLEE'), 'SIMPERJOSEPH', 'JOSEPHSIMPER'), '^BERGERJ', 'JBERGER'), 'FOREMAND', 'DFOREMAN'), 'BERCKENHOFFA', 'BERCKENHOFF') 
	LEFT OUTER JOIN maps.quorum_wells w3 ON
		regexp_replace(regexp_replace(regexp_replace(regexp_replace(
                regexp_replace(
                    regexp_replace(
                        regexp_replace(
                            regexp_replace(
                                regexp_replace(
                                    regexp_replace(regexp_replace(regexp_replace((regexp_match(w3.wellname, '(.*[0-9][0-9]*H).*'))[1], 'NO\W', '', 1, 0, 'i'), 'SA', ''), '^NO', '', 1, 0, 'i'),
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
                                    regexp_replace(regexp_replace(regexp_replace((regexp_match(w1.description, '(.*[0-9][0-9]*H).*'))[1], 'NO\W', '', 1, 0, 'i'), 'SA', ''), '^NO', '', 1, 0, 'i'),
                                'HUNTER', '', 1, 0, 'i'),
                            '[#|-|,|.|\W+]', '', 1, 0, 'i'),
                         '\s{1,}', '', 1, 0, 'i'),
                    'UNIT', '', 1, 0, 'i'),
                 'LTD', 'LIMITED', 1, 0, 'i'), '^JAKEBERGERCC', 'JAKEBERGERJRCATTLECOMPANY'), 'RCRJANE', 'RCRSJANE'), 'McCREARY', 'MCCREARY', 1, 0, 'i'), 'BERCKENHOFFA','BERCKENHOFF')
); 
