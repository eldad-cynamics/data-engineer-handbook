WITH last_season AS (
    SELECT * FROM players
    WHERE current_season = 1998

), this_season AS (
     SELECT * FROM player_seasons
    WHERE season = 1999
)
INSERT INTO players
SELECT
        COALESCE(ls.player_name, ts.player_name) as player_name,
        COALESCE(ls.height, ts.height) as height,
        COALESCE(ls.college, ts.college) as college,
        COALESCE(ls.country, ts.country) as country,
        COALESCE(ls.draft_year, ts.draft_year) as draft_year,
        COALESCE(ls.draft_round, ts.draft_round) as draft_round,
        COALESCE(ls.draft_number, ts.draft_number)
            as draft_number,
        COALESCE(ls.seasons,
            ARRAY[]::season_stats[]
            ) || CASE WHEN ts.season IS NOT NULL THEN
                ARRAY[ROW(
                ts.season,
                ts.pts,
                ts.ast,
                ts.reb, ts.weight)::season_stats]
                ELSE ARRAY[]::season_stats[] END
            as seasons,
         CASE
             WHEN ts.season IS NOT NULL THEN
                 (CASE WHEN ts.pts > 20 THEN 'star'
                    WHEN ts.pts > 15 THEN 'good'
                    WHEN ts.pts > 10 THEN 'average'
                    ELSE 'bad' END)::scoring_class
             ELSE ls.scoring_class
         END as scoring_class,
         ts.season IS NOT NULL as is_active,
         1999 AS current_season

    FROM last_season ls
    FULL OUTER JOIN this_season ts
    ON ls.player_name = ts.player_name



-- DO $$
-- DECLARE
--     prev_year INT;
--     curr_year INT;
-- BEGIN
--     FOR prev_year IN 1996..2021 LOOP
--         curr_year := prev_year + 1;
--
--         EXECUTE format(
--             'WITH last_season AS (
--                 SELECT * FROM players
--                 WHERE current_season = %L
--             ), this_season AS (
--                 SELECT * FROM player_seasons
--                 WHERE season = %L
--             )
--             INSERT INTO players (player_name, height, college, country, draft_year, draft_round, draft_number, seasons, scoring_class, is_active, current_season)
--             SELECT
--                 COALESCE(ls.player_name, ts.player_name) as player_name,
--                 COALESCE(ls.height, ts.height) as height,
--                 COALESCE(ls.college, ts.college) as college,
--                 COALESCE(ls.country, ts.country) as country,
--                 COALESCE(ls.draft_year, ts.draft_year) as draft_year,
--                 COALESCE(ls.draft_round, ts.draft_round) as draft_round,
--                 COALESCE(ls.draft_number, ts.draft_number) as draft_number,
--                 COALESCE(ls.seasons, ARRAY[]::season_stats[]) ||
--                 CASE WHEN ts.season IS NOT NULL THEN
--                     ARRAY[ROW(ts.season, ts.pts, ts.ast, ts.reb, ts.weight)::season_stats]
--                 ELSE ARRAY[]::season_stats[] END as seasons,
--                 CASE
--                     WHEN ts.season IS NOT NULL THEN
--                         (CASE
--                             WHEN ts.pts > 20 THEN ''star''
--                             WHEN ts.pts > 15 THEN ''good''
--                             WHEN ts.pts > 10 THEN ''average''
--                             ELSE ''bad''
--                         END)::scoring_class
--                     ELSE ls.scoring_class
--                 END as scoring_class,
--                 ts.season IS NOT NULL as is_active,
--                 %L AS current_season
--             FROM last_season ls
--             FULL OUTER JOIN this_season ts
--             ON ls.player_name = ts.player_name;',
--             prev_year, curr_year, curr_year
--         );
--     END LOOP;
-- END $$;
