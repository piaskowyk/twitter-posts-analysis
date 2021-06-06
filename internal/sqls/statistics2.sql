-- jaki procent tweetów ma komentarze
with tweet_count as (
    select count(*)
    from tweet
    where type = 1)

select ROUND((cast(count(*) as decimal) / (select * from tweet_count) * 100)::numeric,
             2) as "Procent tweetów, które mają komentarze"
from tweet
where type = 1
  and reply_count > 0;

-- jaki procent tweetów ma retweety
with tweet_count as (
    select count(*)
    from tweet
    where type = 1)

select ROUND((cast(count(*) as decimal) / (select * from tweet_count) * 100)::numeric,
             2) as "Procent tweetów, które mają retweety"
from tweet
where type = 1
  and retweet_count > 0;

-- jaki procent tweetów ma polubienia
with tweet_count as (
    select count(*)
    from tweet
    where type = 1)

select ROUND((cast(count(*) as decimal) / (select * from tweet_count) * 100)::numeric,
             2) as "Procent tweetów, które mają polubienia"
from tweet
where type = 1
  and favorite_count > 0;

-- jaki procent tweetów ma cytowania
with tweet_count as (
    select count(*)
    from tweet
    where type = 1)

select ROUND((cast(count(*) as decimal) / (select * from tweet_count) * 100)::numeric,
             2) as "Procent tweetów, które mają cytowania"
from tweet
where type = 1
  and quote_count > 0;

-- jaki procent tweetów ma więcej niż 100 komentarzy
with tweet_count as (
    select count(*)
    from tweet
    where type = 1)

select ROUND((cast(count(*) as decimal) / (select * from tweet_count) * 100)::numeric,
             2) as "Procent tweetów, które mają więcej niż 100 komentarzy"
from tweet
where type = 1
  and reply_count > 100;

-- jaki procent tweetów ma więcej niż 100 retweetów
with tweet_count as (
    select count(*)
    from tweet
    where type = 1)

select ROUND((cast(count(*) as decimal) / (select * from tweet_count) * 100)::numeric,
             2) as "Procent tweetów, które mają więcej niż 100 retweetów"
from tweet
where type = 1
  and retweet_count > 100;

-- jaki procent tweetów ma więcej niż 100 polubień
with tweet_count as (
    select count(*)
    from tweet
    where type = 1)

select ROUND((cast(count(*) as decimal) / (select * from tweet_count) * 100)::numeric,
             2) as "Procent tweetów, które mają więcej niż 100 polubień"
from tweet
where type = 1
  and favorite_count > 100;

-- jaki procent tweetów ma więcej niż 100 cytowań
with tweet_count as (
    select count(*)
    from tweet
    where type = 1)

select ROUND((cast(count(*) as decimal) / (select * from tweet_count) * 100)::numeric,
             2) as "Procent tweetów, które mają więcej niż 100 cytowań"
from tweet
where type = 1
  and quote_count > 100;