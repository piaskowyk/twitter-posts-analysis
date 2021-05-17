-- top 10 tweetow z najwieksza iloscia komentarzy
select t.content as "Tweet", u.name as "Nazwa użytkownika", t.reply_count as "Ilość komentarzy"
from tweet t
         join "user" u on t.user_id = u.id
order by reply_count desc
limit 10;

-- top 10 tweetow z najwieksza iloscia retweetow
select t.content as "Tweet", u.name as "Nazwa użytkownika", t.retweet_count as "Ilość retweetów"
from tweet t
         join "user" u on t.user_id = u.id
order by retweet_count desc
limit 10;

-- top 10 tweetow z najwieksza iloscia cytowan
select t.content as "Tweet", u.name as "Nazwa użytkownika", t.quote_count as "Ilość cytowań"
from tweet t
         join "user" u on t.user_id = u.id
order by quote_count desc
limit 10;

-- top 10 tweetow z najwieksza iloscia polubien
select t.content as "Tweet", u.name as "Nazwa użytkownika", t.favorite_count as "Ilość polubień"
from tweet t
         join "user" u on t.user_id = u.id
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




