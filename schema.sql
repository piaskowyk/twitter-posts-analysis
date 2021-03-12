CREATE TABLE public."user" (
	id int4 NOT NULL,
	"name" varchar NULL,
	CONSTRAINT user_pkey PRIMARY KEY (id)
);

CREATE TABLE public.tweet (
	id int4 NOT NULL,
	"content" text NULL,
	tags text NULL,
	user_id int4 NULL,
	CONSTRAINT tweet_pk PRIMARY KEY (id)
);

ALTER TABLE public.tweet ADD CONSTRAINT fk_tweet_user FOREIGN KEY (user_id) REFERENCES "user"(id);