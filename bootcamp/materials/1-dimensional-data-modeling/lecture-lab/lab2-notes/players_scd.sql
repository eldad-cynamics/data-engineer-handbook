WITH with_previous AS (
    select actor,
        current_year,
        quality_class,
        is_active,
        LAG(quality_class, 1) OVER (
            PARTITION BY actor
            ORDER BY current_year
        ) as previous_scoring_class,
        LAG(is_active, 1) OVER (
            PARTITION BY actor
            ORDER BY current_year
        ) as previous_is_active
    from actors
),
with_indicators AS (
    select *,
        CASE
            WHEN quality_class <> previous_scoring_class THEN 1
            WHEN is_active <> previous_is_active THEN 1
            ELSE 0
        END AS change_indicator
    from with_previous
),
with_streaks AS (
    select *,
        SUM(change_indicator) OVER(
            PARTITION BY actor
            ORDER BY current_year
        ) AS streak_identifier
    from with_indicators
)

select actor,
    quality_class,
    is_active,
    --streak_identifier,
    MIN(current_year) as start_season,
    MAX(current_year) as end_season
from with_streaks
group by actor,
    streak_identifier,
    is_active,
    quality_class
order by actor, streak_identifier;
