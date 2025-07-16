DROP TABLE maps.wells_merged_by_name CASCADE;

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
	wl2_begindt,
	wl2_enddt,
	case 
		WHEN w3.wl_type2='NULL' THEN '' 
		WHEN wl2_begindt='NULL' and wl2_enddt='NULL' THEN ''
		when wl2_begindt='NULL' then 'TO ' || to_char(to_date(wl2_enddt, 'YYYY-MM-DD'), 'YYYY-MM-DD') 
		WHEN wl2_enddt='NULL' THEN 'FROM ' || to_char(to_date(wl2_begindt, 'YYYY-MM-DD'), 'YYYY-MM-DD')
		ELSE to_char(to_date(wl2_begindt, 'YYYY-MM-DD'), 'YYYY-MM-DD') || ' TO ' || to_char(to_date(wl2_enddt, 'YYYY-MM-DD'), 'YYYY-MM-DD') 
	END as "GL1 Range",
	w3.wl_type1 AS gl2,
	wl1_begindt,
	wl1_enddt,
	case
                WHEN w3.wl_type1='NULL' THEN ''
                WHEN wl1_begindt='NULL' and wl1_enddt='NULL' THEN ''
                when wl1_begindt='NULL' then 'TO ' || to_char(to_date(wl1_enddt, 'YYYY-MM-DD'), 'YYYY-MM-DD')
                WHEN wl1_enddt='NULL' THEN 'FROM ' || to_char(to_date(wl1_begindt, 'YYYY-MM-DD'), 'YYYY-MM-DD')
		WHEN to_char(wl1_enddt::date, 'YYYY-MM-DD')='9000-12-31' THEN to_char(to_date(wl1_begindt, 'YYYY-MM-DD'), 'YYYY-MM-DD') || ' TO ' || 'current'
                ELSE to_char(to_date(wl1_begindt, 'YYYY-MM-DD'), 'YYYY-MM-DD') || ' TO ' || to_char(to_date(wl1_enddt, 'YYYY-MM-DD'), 'YYYY-MM-DD')
        END as "GL2 Range",
	(regexp_match(
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
                                                                                regexp_replace(w1.description, '(DUBOSE UNIT)(.*\yNO\y)(.*)', '\1\3', 1, 0),
                                                                                '(DUBOSE UNIT.*)(WELL)(.*)', '\1\3'
                                                                        ),
                                                                '\(SA\)', '', 1, 0),
                                                'HUNTER', '', 1, 0, 'i'),
                                                '[#|-|,|.|\W+]', '', 1, 0, 'i'),
                                                        'UNIT', '', 1, 0, 'i'),
                                                'LTD', 'LIMITED', 1, 0, 'i'),
                                        '^JAKEBERGERCC', 'JAKEBERGERJRCATTLECOMPANY'),
                                'RCRJANE', 'RCRSJANE'),
                        'McCREARY', 'MCCREARY', 1, 0, 'i'),
                'BERCKENHOFFA', 'BERCKENHOFF'), '(.*[0-9]{1,}\s*H).*'))[1]
description_nowhitespace,
	(regexp_match(
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
                regexp_replace(
                regexp_replace(
                regexp_replace(
                regexp_replace(
                regexp_replace(
                regexp_replace(
                regexp_replace(
                regexp_replace(
                        regexp_replace(w2.well_name, '(DUBOSE)(.*UNIT NO)(.*)', '\1\3', 1, 0),
                        '(EBONY).*([0-9]H)', '\1\2'
                ),
                'WAVELITE', 'WAVELLITE'),
                '\(SA\)', '', 1, 0),
                '[#|-|,|.|\W+]', '', 1, 0 , 'i'),
                'HUNTER', '', 1, 0, 'i'),
                'UNIT', '', 1, 0, 'i'),
                'LTD', 'LIMITED', 1, 0, 'i'),
                '^JAKEBERGERCC', 'JAKEBERGERJRCATTLECOMPANY'),
                'SHINERRANCHSOUTHERN', 'SHINERRANCHS', 1, 0, 'i'),
                'WASHINGTONR', 'RWASHINGTON'),
                'SCHAEFERRL', 'RLSCHAEFER'),
                'McCREARY', 'MCCREARY', 1, 0, 'i'),
                '^LEELJ', 'LJLEE'),
                'SIMPERJOSEPH', 'JOSEPHSIMPER'),
                '^BERGERJ', 'JBERGER'),
                'FOREMAND', 'DFOREMAN'),
                'BERCKENHOFFA', 'BERCKENHOFF'),
                '(SOUTHERNBOCK)[AB]', '\1'),
                '(SOUTHERNAMBER)[0-9]([0-9]H)', '\1\2'),
        '\s\s*', '', 1, 0), '(.*[0-9]{1,}\s*H).*'))[1]
baytex_wells_nowhitespace,
(regexp_match(
                regexp_replace(
                        regexp_replace(
                                regexp_replace(
                                        regexp_replace(
                                                regexp_replace(
                                                        regexp_replace(
                                                                regexp_replace(
                                                                        regexp_replace(
                                                                                regexp_replace(
                                                                                        regexp_replace(w3.wellname, '(DUBOSE UNIT)(.*\yNO\y)(.*)', '\1\3'),
                                                                                '\(SA\)', '', 1, 0),
                                                                        'HUNTER', '', 1, 0, 'i'),
                                                                '[#|-|,|.|\W+]', '', 1, 0, 'i'),
                                                        'UNIT', '', 1, 0, 'i'),
                                                'LTD', 'LIMITED', 1, 0, 'i'),
                                        '^JAKEBERGERCC', 'JAKEBERGERJRCATTLECOMPANY'),
                                'RCRJANE', 'RCRSJANE'),
                        'McCREARY', 'MCCREARY', 1, 0, 'i'),
                'BERCKENHOFFA', 'BERCKENHOFF'), '(.*[0-9]{1,}\s*H).*'))[1]
quorum_well_nowhitespace
FROM	     
    master_list_of_baytex_wells w1 LEFT JOIN maps.baytex_wells w2 
ON
	(regexp_match(
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
                	regexp_replace(w1.description, '(DUBOSE UNIT)(.*\yNO\y)(.*)', '\1\3', 1, 0),
		'(DUBOSE UNIT.*)(WELL)(.*)', '\1\3'),
		'(EBONY).*([0-9]H)', '\1\2'),
		'\(SA\)', '', 1, 0),
                'HUNTER', '', 1, 0, 'i'),
                '[#|-|,|.|\W+]', '', 1, 0, 'i'),
                'UNIT', '', 1, 0, 'i'),
                'LTD', 'LIMITED', 1, 0, 'i'),
                '^JAKEBERGERCC', 'JAKEBERGERJRCATTLECOMPANY'),
                'RCRJANE', 'RCRSJANE'),
                'McCREARY', 'MCCREARY', 1, 0, 'i'),
                'BERCKENHOFFA', 'BERCKENHOFF'), 
	'(.*[0-9]{1,}\s*H).*'))[1]
                                = (regexp_match(
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
		regexp_replace(
		regexp_replace(
		regexp_replace(
		regexp_replace(
		regexp_replace(
		regexp_replace(
		regexp_replace(
		regexp_replace(
			regexp_replace(w2.well_name, '(DUBOSE)(.*UNIT NO)(.*)', '\1\3', 1, 0),
		'(EBONY).*([0-9]H)', '\1\2'),
		'WAVELITE', 'WAVELLITE'),
		'\(SA\)', '', 1, 0),
		'[#|-|,|.|\W+]', '', 1, 0 , 'i'),
		'HUNTER', '', 1, 0, 'i'),
                'UNIT', '', 1, 0, 'i'), 
                'LTD', 'LIMITED', 1, 0, 'i'), 
                '^JAKEBERGERCC', 'JAKEBERGERJRCATTLECOMPANY'), 
		'SHINERRANCHSOUTHERN', 'SHINERRANCHS', 1, 0, 'i'),
		'WASHINGTONR', 'RWASHINGTON'), 
		'SCHAEFERRL', 'RLSCHAEFER'), 
		'McCREARY', 'MCCREARY', 1, 0, 'i'), 
		'^LEELJ', 'LJLEE'), 
		'SIMPERJOSEPH', 'JOSEPHSIMPER'), 
		'^BERGERJ', 'JBERGER'), 
		'FOREMAND', 'DFOREMAN'), 
		'BERCKENHOFFA', 'BERCKENHOFF'),
       		'(SOUTHERNBOCK)[AB]', '\1'),
		'(SOUTHERNAMBER)[0-9]([0-9]H)', '\1\2'),
		'\s\s*', '', 1, 0), 
		'(.*[0-9]{1,}\s*H).*'))[1] 
LEFT JOIN maps.quorum_wells w3 
ON
	(regexp_match(
		regexp_replace(
			regexp_replace(
				regexp_replace(
					regexp_replace(
						regexp_replace(
                					regexp_replace(
                        					regexp_replace(
                            						regexp_replace(
										regexp_replace(
											regexp_replace(w3.wellname, '(DUBOSE UNIT)(.*\yNO\y)(.*)', '\1\3'),
                                						'\(SA\)', '', 1, 0), 
                                					'HUNTER', '', 1, 0, 'i'),
                            					'[#|-|,|.|\W+]', '', 1, 0, 'i'),
                    					'UNIT', '', 1, 0, 'i'),
                 				'LTD', 'LIMITED', 1, 0, 'i'), 
					'^JAKEBERGERCC', 'JAKEBERGERJRCATTLECOMPANY'), 
				'RCRJANE', 'RCRSJANE'), 
			'McCREARY', 'MCCREARY', 1, 0, 'i'), 
		'BERCKENHOFFA', 'BERCKENHOFF'), '(.*[0-9]{1,}\s*H).*'))[1] = 
(regexp_match(
                regexp_replace(
                	regexp_replace(
                        	regexp_replace(
                        	regexp_replace(
                                regexp_replace(
                                regexp_replace(
                                                regexp_replace(
                                                        regexp_replace(
                                                                regexp_replace(
									regexp_replace(w1.description, '(DUBOSE UNIT)(.*NO.*)( [0-9] )(\yWELL\y)*(.*)', '\1\3\5'),
                                                        	'\(SA\)', '', 1, 0),
                                                'HUNTER', '', 1, 0, 'i'),
                                                '[#|-|,|.|\W+]', '', 1, 0, 'i'),
                                                'UNIT', '', 1, 0, 'i'),
                                                'LTD', 'LIMITED', 1, 0, 'i'),
                                        '^JAKEBERGERCC', 'JAKEBERGERJRCATTLECOMPANY'),
                                'RCRJANE', 'RCRSJANE'),
                        'McCREARY', 'MCCREARY', 1, 0, 'i'),
                'BERCKENHOFFA', 'BERCKENHOFF'), '(.*[0-9]{1,}\s*H).*'))[1]
);
