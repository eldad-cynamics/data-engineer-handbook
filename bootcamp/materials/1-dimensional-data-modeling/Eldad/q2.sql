-- Cumulative table generation query: Write a query that populates the actors table one year at a time.

WITH last_season AS (
    SELECT * FROM actors
    WHERE current_year = 1969

), this_season AS (
     SELECT * FROM actor_films
    WHERE year = 1970
)
INSERT INTO actors

SELECT

        COALESCE(ls.actor, ts.actor) as actor,
        COALESCE(ls.actorid, ts.actorid) as actorid,
        COALESCE(ls.film, ts.film) as film,
        COALESCE(ls.year, ts.year) as year,
        COALESCE(ls.votes, ts.votes) as votes,
        COALESCE(ls.rating, ts.rating) as rating,
        COALESCE(ls.filmid, ts.filmid) as filmid,

        COALESCE(ls.films, ARRAY[]::films[]) ||
            CASE WHEN ts.year IS NOT NULL THEN
                ARRAY[ROW(
                ts.year,
                ts.film,
                ts.votes,
                ts.rating, ts.filmid)::films]
            ELSE ARRAY[]::films[] END as films,


        CAST(
            CASE
                WHEN avg(ts.rating) over (partition by ts.actorid) > 8 THEN 'star'
                WHEN avg(ts.rating) over (partition by ts.actorid) > 7 AND avg(ts.rating) over (partition by ts.actorid) <= 8 THEN 'good'
                WHEN avg(ts.rating) over (partition by ts.actorid) > 6 AND avg(ts.rating) over (partition by ts.actorid) <= 7 THEN 'average'
                WHEN avg(ts.rating) over (partition by ts.actorid) <= 6 THEN 'bad'
            END AS quality_class
        ),

        CASE
             when COUNT(ts.filmid) over (partition by ts.actorid) >= 1 then TRUE
             else FALSE
        END as is_active,

         1970 AS current_year

    FROM last_season ls
    FULL OUTER JOIN this_season ts
    ON ls.film = ts.film



-- Loop through the years from 1996 to 2000
DO $$
DECLARE
    prev_year INT;
    curr_year INT;
BEGIN
    FOR prev_year IN 2000..2021 LOOP
        curr_year := prev_year + 1;

        EXECUTE format(
            'WITH last_season AS (
                SELECT * FROM players
                WHERE current_season = %L
            ), this_season AS (
                SELECT * FROM player_seasons
                WHERE season = %L
            )
            INSERT INTO players (player_name, height, college, country, draft_year, draft_round, draft_number, seasons, scoring_class, is_active, current_season)
            SELECT
                COALESCE(ls.player_name, ts.player_name) as player_name,
                COALESCE(ls.height, ts.height) as height,
                COALESCE(ls.college, ts.college) as college,
                COALESCE(ls.country, ts.country) as country,
                COALESCE(ls.draft_year, ts.draft_year) as draft_year,
                COALESCE(ls.draft_round, ts.draft_round) as draft_round,
                COALESCE(ls.draft_number, ts.draft_number) as draft_number,
                COALESCE(ls.seasons, ARRAY[]::season_stats[]) ||
                CASE WHEN ts.season IS NOT NULL THEN
                    ARRAY[ROW(ts.season, ts.pts, ts.ast, ts.reb, ts.weight)::season_stats]
                ELSE ARRAY[]::season_stats[] END as seasons,
                CASE
                    WHEN ts.season IS NOT NULL THEN
                        (CASE
                            WHEN ts.pts > 20 THEN ''star''
                            WHEN ts.pts > 15 THEN ''good''
                            WHEN ts.pts > 10 THEN ''average''
                            ELSE ''bad''
                        END)::scoring_class
                    ELSE ls.scoring_class
                END as scoring_class,
                ts.season IS NOT NULL as is_active,
                %L AS current_season
            FROM last_season ls
            FULL OUTER JOIN this_season ts
            ON ls.player_name = ts.player_name;',
            prev_year, curr_year, curr_year
        );
    END LOOP;
END $$;