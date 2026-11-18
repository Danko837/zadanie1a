-- Active: 1795004124492@@127.0.0.1@5432@movielens_elt

CREATE SCHEMA IF NOT EXISTS gold;

CREATE TABLE gold.dim_user(
    user_id INT NOT NULL UNIQUE,
    gender CHAR(1) NOT NULL CHECK(gender IN('M','F')),
    zip_code VARCHAR(10),
    age_group VARCHAR(20) NOT NULL,
    occupation VARCHAR(50) NOT NULL

);

CREATE TABLE gold.dim_movie(
    movie_id INT NOT NULL UNIQUE,
    title VARCHAR(200) NOT NULL,
    release_year INT,
    genre_name VARCHAR(200) NOT NULL
);

CREATE TABLE gold.dim_date (
    date_id INT PRIMARY KEY,
    rated_at TIME NOT NULL UNIQUE,
    day INT NOT NULL,
    month INT NOT NULL,
    year INT NOT NULL,
    day_of_week INT NOT NULL,
    day_name VARCHAR(10) NOT NULL,
    week INT NOT NULL,
    month_name VARCHAR(10) NOT NULL,
    quarter INT NOT NULL
);
CREATE TABLE gold.dim_time (
    time_id INT PRIMARY KEY,
    rated_at TIME NOT NULL UNIQUE,
    hour INT NOT NULL,
    minute INT NOT NULL,
    second INT NOT NULL,
    time_of_day VARCHAR(10) NOT NULL
);
CREATE TABLE gold.fact_rating(
    rating_id INT PRIMARY KEY,
    user_id INT NOT NULL REFERENCES gold.dim_user (user_id),
    -- movie_id,date_id,time_id
    rating NUMERIC(2,1) NOT NULL CHECK(rating between 1 and 5),
    rating_percentage INT NOT NULL
);

CREATE INDEX ON gold.fact_rating (user_id);
CREATE INDEX ON gold.fact_rating (movie_id);
CREATE INDEX ON gold.fact_rating (date_id);
CREATE INDEX ON gold.fact_rating (time_id);

BEGIN;

TRUNCATE gold.fact_rating,
gold.dim_user,
gold.dim_movie,
gold.dim_date,
gold.dim_time;



INSERT INTO
    gold.dim_user (
        user_id,
        gender,
        zip_code,
        age_group,
        occupation
    )
    SELECT u.user_id, u.gender, u.zip_code, COALESCE(a.age_group_name, 'unknown'), COALESCE(o.occupation_name, 'unknown')
    FROM silver.stg_users u 
    LEFT JOIN siver.stg_age_groups a on a.age_group_id = u.age
    LEFT JOIN silver.stg_occupations o ON o.occupation_id = u.occupation_id
    ORDER BY u.user_id;
INSERT INTO gold.dim_movie (
    movie_id,
    title,
    release_year,
    genre_name
);
SELECT m.movie_id, m.title, m.release_year, COALESCE(g.genre_name, 'unknown')
FROM silver.stg_movies m 
LEFT JOIN (
    SELECT gm.movie_id, STRING_AGG(
        g.genre_name, ','
        ORDER BY g.genre_name
    ) AS genre_name
    FROM silver.stg.genre_movies gm 
    JOIN silver.stg_genres g on g.genre_id = gm.genre_id

)