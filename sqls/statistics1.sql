-- userzy którzy pisali same pozytywne tweety
select u.name
from "user" u
where u.id not in (select t.user_id
                   from tweet t
                   where t.type = 1
                     and t.sentiment_compound < 0.05);

-- userzy którzy pisali same pozytywne komentarze
select u.name
from "user" u
where u.id not in (select t.user_id
                   from tweet t
                   where t.type = 2
                     and t.sentiment_compound < 0.05);

-- userzy którzy pisali same negatywne tweety
select u.name
from "user" u
where u.id not in (select t.user_id
                   from tweet t
                   where t.type = 1
                     and t.sentiment_compound > 0.05);

-- userzy którzy pisali same negatywne komentarze
select u.name
from "user" u
where u.id not in (select t.user_id
                   from tweet t
                   where t.type = 2
                     and t.sentiment_compound > 0.05);

-- ilosc wszystkich tweetów
select count(*)
from tweet t
where t.type = 1;

-- ilosc wszystkich komentarzy
select count(*)
from tweet t
where t.type = 2;

-- ilosc wszystkich cytowań
select count(*)
from tweet t
where t.type = 3;

-- ilosc wszystkich retweetów
select count(*)
from retweet;

-- ilosc wszystkich polubień
select sum(t.favorite_count)
from tweet t;

-- srednia ilosc komentarzy per tweet
select avg(t.reply_count)
from tweet t
where t.type = 1;

-- srednia ilosc retweetow per tweet
select avg(t.retweet_count)
from tweet t
where t.type = 1;

-- srednia ilosc polubien per tweet
select avg(t.favorite_count)
from tweet t
where t.type = 1;

-- srednia ilosc cytowan per tweet
select avg(t.quote_count)
from tweet t
where t.type = 1;



