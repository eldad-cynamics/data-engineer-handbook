-- playing with window functions
select
    actor,
    film,
    year,
    rating,
    sum(rating) over (partition by actor order by year) as rating_order_by_film,
    sum(rating) over (partition by actor) as rating_order_without_by,
    row_number() over (partition by actor order by rating desc ) as row_number_by_actor_for_rating,
    row_number() over (order by rating desc),
    rank() over (order by rating desc),
    dense_rank() over (order by rating desc)
from actor_films
order by rating desc