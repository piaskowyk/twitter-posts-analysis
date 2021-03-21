CREATE TABLE public."user" (
	id int8 NOT NULL,
	"name" varchar NULL,
	"location" varchar NULL,
	description varchar NULL,
	followers_count int4 NULL,
	CONSTRAINT user_pkey PRIMARY KEY (id)
);

CREATE TABLE public.tweet (
	id int8 NOT NULL,
	"content" text NULL,
	tags text NULL,
	user_id int8 NULL,
	CONSTRAINT tweet_pk PRIMARY KEY (id)
);

ALTER TABLE public.tweet ADD CONSTRAINT fk_tweet_user null;