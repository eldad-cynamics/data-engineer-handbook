create table players_scd
(
	player_name text,
	scoring_class scoring_class,
	is_active boolean,
	start_date integer,
	end_date integer,
	current_year INTEGER,
    PRIMARY KEY(player_name, start_date)
);
