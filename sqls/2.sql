-- top 10 tweetow z najwieksza iloscia komentarzy
select t.id as "Identyfikator tweeta", t.content as "Tweet"
from tweet t
order by reply_count desc
limit 10;

-- top 10 tweetow z najwieksza iloscia retweetow
select t.id as "Identyfikator tweeta", t.content as "Tweet"
from tweet t
order by retweet_count desc
limit 10;

-- top 10 tweetow z najwieksza iloscia cytowan
select t.id as "Identyfikator tweeta", t.content as "Tweet"
from tweet t
order by quote_count desc
limit 10;

-- top 10 tweetow z najwieksza iloscia polubien
select t.id as "Identyfikator tweeta", t.content as "Tweet"
from tweet t
order by favorite_count desc
limit 10;

-- top 10 userow którzy otrzymali najwięcej polubień pod swoimi tweetami
select u.name as "Nazwa użytkownika", t.favorite_count as "Liczba polubień pod tweetami"
from "user" u
         join tweet t on u.id = t.user_id
where t.type = 1
order by t.favorite_count desc
limit 10;

-- top 10 userow którzy otrzymali najwięcej polubień pod swoimi komentarzami
select u.name as "Nazwa użytkownika", t.favorite_count as "Liczba polubień pod komentarzami"
from "user" u
         join tweet t on u.id = t.user_id
where t.type = 2
order by t.favorite_count desc
limit 10;




