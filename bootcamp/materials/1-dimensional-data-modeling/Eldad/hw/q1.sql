-- DDL for actors table: Create a DDL for an actors table with the following fields:
--
-- films: An array of struct with the following fields:
--
-- film: The name of the film.
-- votes: The number of votes the film received.
-- rating: The rating of the film.
-- filmid: A unique identifier for each film.
-- quality_class: This field represents an actor's performance quality, determined by the average rating of movies of their most recent year. It's categorized as follows:
--
-- star: Average rating > 8.
-- good: Average rating > 7 and ≤ 8.
-- average: Average rating > 6 and ≤ 7.
-- bad: Average rating ≤ 6.
-- is_active: A BOOLEAN field that indicates whether an actor is currently active in the film industry (i.e., making films this year).

CREATE TYPE films_array AS (
    year INTEGER,
    film TEXT,
    votes INTEGER,
    rating REAL,
    filmid TEXT
);
 CREATE TYPE quality_class AS
     ENUM ('bad', 'average', 'good', 'star');


CREATE TABLE actors (
                        actor TEXT,
                        actorid TEXT,
                        films films_array[],
                        is_active BOOLEAN,
                        current_year INTEGER,
                        quality_class quality_class,
                        PRIMARY KEY (actorid,current_year)
);
