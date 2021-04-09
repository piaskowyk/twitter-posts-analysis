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
	CONSTRAINT tweet_pk PRIMARY KEY (id)
);

ALTER TABLE public.tweet ADD CONSTRAINT fk_tweet_user null;
