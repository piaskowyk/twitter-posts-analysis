-- top 10 tweetow z najwieksza iloscia komentarzy
select t.id, t.content, t.user_id
from tweet t
order by reply_count desc
limit 10;

-- top 10 tweetow z najwieksza iloscia retweetow
select t.id, t.content, t.user_id
from tweet t
order by retweet_count desc
limit 10;

-- top 10 tweetow z najwieksza iloscia cytowan
select t.id, t.content, t.user_id
from tweet t
order by quote_count desc
limit 10;

-- top 10 tweetow z najwieksza iloscia polubien
select t.id, t.content, t.user_id
from tweet t
order by favorite_count desc
limit 10;

-- top 10 userow którzy otrzymali najwięcej polubień pod swoimi tweetami
select u.name, t.favorite_count
from "user" u
         join tweet t on u.id = t.user_id
where t.type = 1
order by t.favorite_count desc



