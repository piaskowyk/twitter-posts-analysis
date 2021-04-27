-- public."user" definition

-- Drop table

-- DROP TABLE public."user";

CREATE TABLE public."user" (
	id int8 NOT NULL,
	"name" varchar NULL,
	"location" varchar NULL,
	description varchar NULL,
	followers_count int4 NULL,
	friends_count int4 NULL,
	media_count int4 NULL,
	favourites_count int4 NULL,
	CONSTRAINT user_pkey PRIMARY KEY (id)
);

-- public.tweet definition

-- Drop table

-- DROP TABLE public.tweet;

CREATE TABLE public.tweet (
	id int8 NOT NULL,
	"content" text NULL,
	tags text NULL,
	user_id int8 NULL,
	created_at timestamp(0) NULL,
	sentiment_neg float4 NULL,
	sentiment_neu float4 NULL,
	sentiment_pos float4 NULL,
	sentiment_compound float4 NULL,
	retweet_count int4 NULL,
	favorite_count int4 NULL,
	reply_count int4 NULL,
	quote_count int4 NULL,
	reply_to int8 NULL,
	fetched_comments bool NULL,
	"type" int4 NULL,
	fetched_retweets bool NULL,
	fetched_quotes bool NULL,
	CONSTRAINT tweet_pk PRIMARY KEY (id)
);


-- public.tweet foreign keys

ALTER TABLE public.tweet ADD CONSTRAINT fk_tweet_user FOREIGN KEY (user_id) REFERENCES "user"(id);

-- public.retweet definition

-- Drop table

-- DROP TABLE public.retweet;

CREATE TABLE public.retweet (
	id bigserial NOT NULL,
	user_id int8 NULL,
	tweet_id int8 NULL,
	CONSTRAINT retweet_pk PRIMARY KEY (id)
);


-- public.retweet foreign keys

ALTER TABLE public.retweet ADD CONSTRAINT retweet_fk FOREIGN KEY (user_id) REFERENCES "user"(id);
ALTER TABLE public.retweet ADD CONSTRAINT retweet_fk_1 FOREIGN KEY (tweet_id) REFERENCES tweet(id);

CREATE TABLE public."cursor" (
	id serial NOT NULL,
	"date" date NULL,
	"cursor" varchar NULL,
	count int4 NULL DEFAULT 0,
	CONSTRAINT cursor_pk PRIMARY KEY (id)
);

--CREATE SEQUENCE cursor_id_seq;
--ALTER SEQUENCE cursor_id_seq OWNED BY "cursor".id;
--
--CREATE SEQUENCE retweet_id_seq;
--ALTER SEQUENCE retweet_id_seq OWNED BY retweet.id;

INSERT INTO public."cursor"
(id, "date", "cursor", count)
VALUES(1, '2020-03-01', NULL, 0);