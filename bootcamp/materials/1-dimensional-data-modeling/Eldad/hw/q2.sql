WITH last_season AS (
    SELECT *
    FROM actors
    WHERE current_year = 1971
),
this_season_grouped_data AS (
    SELECT
        ts.actor,
        ts.actorid,
        array_agg(
            ROW(
                ts.year,
                ts.film,
                ts.votes,
                ts.rating,
                ts.filmid
            )::films_array
        ) AS films,
        avg(ts.rating) AS avg_rating
    FROM actor_films ts
    WHERE year = 1972
    GROUP BY
        ts.actor,
        ts.actorid
)
INSERT INTO actors (
    actor,
    actorid,
    films,
    is_active,
    current_year,
    quality_class
)
SELECT
    COALESCE(ls.actor, gd.actor) AS actor,
    COALESCE(ls.actorid, gd.actorid) AS actorid,
    COALESCE(ls.films, ARRAY[]::films_array[]) ||
    COALESCE(gd.films, ARRAY[]::films_array[]) AS films,
    CASE
        WHEN gd.actorid IS NOT NULL THEN TRUE
        ELSE FALSE
    END AS is_active,
    1972 AS current_year,
    CAST(
        CASE
            WHEN gd.avg_rating > 8 THEN 'star'
            WHEN gd.avg_rating <= 8 AND gd.avg_rating > 7 THEN 'good'
            WHEN gd.avg_rating <= 7 AND gd.avg_rating > 6 THEN 'average'
            ELSE 'bad'
        END AS quality_class
    ) AS quality_class
FROM last_season ls
FULL OUTER JOIN this_season_grouped_data gd
    ON ls.actorid = gd.actorid;
--
-- DO $$
-- DECLARE
--     prev_year INT;
--     curr_year INT;
-- BEGIN
--     FOR prev_year IN 1969..2020 LOOP
--         curr_year := prev_year + 1;
--
--         EXECUTE format(
--             'WITH last_season AS (
--                 SELECT *
--                 FROM actors
--                 WHERE current_year = %L
--             ),
--             this_season_grouped_data AS (
--                 SELECT
--                     ts.actor,
--                     ts.actorid,
--                     array_agg(
--                         ROW(
--                             ts.year,
--                             ts.film,
--                             ts.votes,
--                             ts.rating,
--                             ts.filmid
--                         )::films_array
--                     ) AS films,
--                     avg(ts.rating) AS avg_rating
--                 FROM actor_films ts
--                 WHERE year = %L
--                 GROUP BY
--                     ts.actor,
--                     ts.actorid
--             )
--             INSERT INTO actors (
--                 actor,
--                 actorid,
--                 films,
--                 is_active,
--                 current_year,
--                 quality_class
--             )
--             SELECT
--                 COALESCE(ls.actor, gd.actor) AS actor,
--                 COALESCE(ls.actorid, gd.actorid) AS actorid,
--                 COALESCE(ls.films, ARRAY[]::films_array[]) ||
--                 COALESCE(gd.films, ARRAY[]::films_array[]) AS films,
--                 CASE
--                     WHEN gd.actorid IS NOT NULL THEN TRUE
--                     ELSE FALSE
--                 END AS is_active,
--                 %L AS current_year,
--                 CAST(
--                     CASE
--                         WHEN gd.avg_rating > 8 THEN ''star''
--                         WHEN gd.avg_rating <= 8 AND gd.avg_rating > 7 THEN ''good''
--                         WHEN gd.avg_rating <= 7 AND gd.avg_rating > 6 THEN ''average''
--                         ELSE ''bad''
--                     END AS quality_class
--                 ) AS quality_class
--             FROM last_season ls
--             FULL OUTER JOIN this_season_grouped_data gd
--                 ON ls.actorid = gd.actorid;',
--                         prev_year, curr_year, curr_year
--         );
--     END LOOP;
-- END $$;