-- Create Movie Ratings PostgreSQL database schema (DDL)

DROP TABLE IF EXISTS public.ratings;

DROP TABLE IF EXISTS public.tags;

DROP TABLE IF EXISTS public.links;

DROP TABLE IF EXISTS public.movies;

DROP SCHEMA IF EXISTS public;

CREATE SCHEMA public;

COMMENT ON SCHEMA public IS 'standard public schema';

ALTER SCHEMA public OWNER TO masteruser;

CREATE TABLE IF NOT EXISTS public.movies (
    movieId bigint NOT NULL CONSTRAINT movies_pkey PRIMARY KEY,
    title text NOT NULL,
    genres text NOT NULL
);

ALTER TABLE public.movies OWNER TO masteruser;

CREATE TABLE IF NOT EXISTS public.ratings (
    userId bigint NOT NULL,
    movieId bigint NOT NULL CONSTRAINT ratings_movies_movie_id_fk REFERENCES public.movies ON UPDATE CASCADE ON DELETE RESTRICT,
    rating numeric(2, 1) NOT NULL,
    timestamp bigint NOT NULL
);

ALTER TABLE public.ratings OWNER TO masteruser;

CREATE TABLE IF NOT EXISTS public.links (
    movieId bigint NOT NULL CONSTRAINT links_movies_movie_id_fk REFERENCES public.movies ON UPDATE CASCADE ON DELETE RESTRICT,
    imdbId bigint NOT NULL,
    tmdbId bigint NOT NULL
);

ALTER TABLE public.links OWNER TO masteruser;

CREATE TABLE IF NOT EXISTS public.tags (
    userId bigint NOT NULL,
    movieId bigint NOT NULL CONSTRAINT tags_movies_movie_id_fk REFERENCES public.movies ON UPDATE CASCADE ON DELETE RESTRICT,
    tag text NOT NULL,
    timestamp bigint NOT NULL
);

ALTER TABLE public.tags OWNER TO masteruser;

