-- top 10 userów którzy napisali najwięcej tweetów
select u.name as "Nazwa użytkownika", count(*) as "Liczba tweetów"
from "user" u
         join tweet t on u.id = t.user_id
where t.reply_to is null
  and t.type = 1
group by u.id, u.name
order by count(*) desc
limit 10;

-- top 10 userów którzy napisali najwięcej komentarzy
select u.name as "Nazwa użytkownika", count(*) as "Liczba komentarzy"
from "user" u
         join tweet t on u.id = t.user_id
where t.type = 2
group by u.id, u.name
order by count(*) desc
limit 10;

-- top 10 userów którzy napisali najwięcej pozytywnych tweetow
select u.name as "Nazwa użytkownika", count(*) as "Liczba pozytywnych tweetow"
from "user" u
         join tweet t on u.id = t.user_id
where t.reply_to is null
  and t.type = 1
  and t.sentiment_compound >= 0.05
group by u.id, u.name
order by count(*) desc
limit 10;

-- top 10 userów którzy napisali najwięcej negatywnych tweetow
select u.name as "Nazwa użytkownika", count(*) as "Liczba negatywnych tweetow"
from "user" u
         join tweet t on u.id = t.user_id
where t.reply_to is null
  and t.type = 1
  and t.sentiment_compound <= -0.05
group by u.id, u.name
order by count(*) desc
limit 10;


-- top 10 userów którzy napisali najwięcej pozytywnych komentarzy
select u.name as "Nazwa użytkownika", count(*) as "Liczba pozytywnych komentarzy"
from "user" u
         join tweet t on u.id = t.user_id
where t.type = 2
  and t.sentiment_compound >= 0.05
group by u.id, u.name
order by count(*) desc
limit 10;

-- top 10 userów którzy napisali najwięcej negatywnych komentarzy
select u.name as "Nazwa użytkownika", count(*) as "Liczba negatywnych komentarzy"
from "user" u
         join tweet t on u.id = t.user_id
where t.type = 2
  and t.sentiment_compound <= -0.05
group by u.id, u.name
order by count(*) desc
limit 10;

-- top 10 najpopularniejszych tweetow z największą ilością komentarzy + retweetów + cytowań + polubień
select t.id as "Identyfikator tweeta", t.content as "Treść tweeta", t.reply_count + t.retweet_count + t.quote_count + t.favorite_count as "Suma komentarzy, retweetów cytowań i polubień"
from tweet t
where t.type = 1
order by "Suma komentarzy, retweetów cytowań i polubień" desc
limit 10;
