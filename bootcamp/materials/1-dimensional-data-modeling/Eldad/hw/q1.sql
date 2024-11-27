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
