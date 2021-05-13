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

-- srednia ilosc komentarzy per tweet na dzien
select avg(t.reply_count) as "Srednia liczba komentarzy na dzien", date_trunc('day', t.created_at) as day
from tweet t
where t.type = 1
group by day
order by day desc;

-- srednia ilosc komentarzy per tweet na tydzien
select avg(t.reply_count) as "Srednia liczba komentarzy na tydzien", date_trunc('week', t.created_at) as week
from tweet t
where t.type = 1
group by week
order by week desc;

-- srednia ilosc komentarzy per tweet na miesiac
select avg(t.reply_count) as "Srednia liczba komentarzy na miesiac", date_trunc('month', t.created_at) as month
from tweet t
where t.type = 1
group by month
order by month desc;


-- srednia ilosc retweetow per tweet na dzien
select avg(t.retweet_count) as "Srednia liczba retweetow na dzien", date_trunc('day', t.created_at) as day
from tweet t
where t.type = 1
group by day
order by day desc;

-- srednia ilosc retweetow per tweet na tydzien
select avg(t.retweet_count) as "Srednia liczba retweetow na tydzien", date_trunc('week', t.created_at) as week
from tweet t
where t.type = 1
group by week
order by week desc;

-- srednia ilosc retweetow per tweet na miesiac
select avg(t.retweet_count) as "Srednia liczba retweetow na miesiac", date_trunc('month', t.created_at) as month
from tweet t
where t.type = 1
group by month
order by month desc;


-- srednia ilosc polubien per tweet na dzien
select avg(t.favorite_count) as "Srednia liczba polubien na dzien", date_trunc('day', t.created_at) as day
from tweet t
where t.type = 1
group by day
order by day desc;

-- srednia ilosc polubien per tweet na tydzien
select avg(t.favorite_count) as "Srednia liczba polubien na tydzien", date_trunc('week', t.created_at) as week
from tweet t
where t.type = 1
group by week
order by week desc;

-- srednia ilosc polubien per tweet na miesiac
select avg(t.favorite_count) as "Srednia liczba polubien na miesiac", date_trunc('month', t.created_at) as month
from tweet t
where t.type = 1
group by month
order by month desc;


-- srednia ilosc cytowan per tweet na dzien
select avg(t.quote_count) as "Srednia liczba cytowan na dzien", date_trunc('day', t.created_at) as day
from tweet t
where t.type = 1
group by day
order by day desc;

-- srednia ilosc cytowan per tweet na tydzien
select avg(t.quote_count) as "Srednia liczba cytowan na tydzien", date_trunc('week', t.created_at) as week
from tweet t
where t.type = 1
group by week
order by week desc;

-- srednia ilosc cytowan per tweet na miesiac
select avg(t.quote_count) as "Srednia liczba cytowan na miesiac", date_trunc('month', t.created_at) as month
from tweet t
where t.type = 1
group by month
order by month desc;


-- srednia ilosc pozytywnych komentarzy per tweet
select avg(count)
from (select count(*) as count
      from tweet t
               join tweet t2 on t.id = t2.reply_to
      where t.type = 1
        and t2.type = 2
        and t2.sentiment_compound >= 0.05
      group by t.id
      order by count desc) as counts;

-- srednia ilosc negatywnych komentarzy per tweet
select avg(count)
from (select count(*) as count
      from tweet t
               join tweet t2 on t.id = t2.reply_to
      where t.type = 1
        and t2.type = 2
        and t2.sentiment_compound <= -0.05
      group by t.id
      order by count desc) as counts;


-- srednia ilosc pozytywnych komentarzy per tweet per dzien
select avg(count), day
from (select count(*) as count, date_trunc('day', t.created_at) as day
      from tweet t
               join tweet t2 on t.id = t2.reply_to
      where t.type = 1
        and t2.type = 2
        and t2.sentiment_compound >= 0.05
      group by t.id, day
      order by count desc) as res
group by day;

-- srednia ilosc pozytywnych komentarzy per tweet per tydzien
select avg(count), week
from (select count(*) as count, date_trunc('week', t.created_at) as week
      from tweet t
               join tweet t2 on t.id = t2.reply_to
      where t.type = 1
        and t2.type = 2
        and t2.sentiment_compound >= 0.05
      group by t.id, week
      order by count desc) as res
group by week;

-- srednia ilosc pozytywnych komentarzy per tweet per miesiac
select avg(count), month
from (select count(*) as count, date_trunc('month', t.created_at) as month
      from tweet t
               join tweet t2 on t.id = t2.reply_to
      where t.type = 1
        and t2.type = 2
        and t2.sentiment_compound >= 0.05
      group by t.id, month
      order by count desc) as res
group by month;


-- srednia ilosc negatywnych komentarzy per tweet per dzien
select avg(count), day
from (select count(*) as count, date_trunc('day', t.created_at) as day
      from tweet t
               join tweet t2 on t.id = t2.reply_to
      where t.type = 1
        and t2.type = 2
        and t2.sentiment_compound <= -0.05
      group by t.id, day
      order by count desc) as res
group by day;

-- srednia ilosc negatywnych komentarzy per tweet per tydzien
select avg(count), week
from (select count(*) as count, date_trunc('week', t.created_at) as week
      from tweet t
               join tweet t2 on t.id = t2.reply_to
      where t.type = 1
        and t2.type = 2
        and t2.sentiment_compound <= -0.05
      group by t.id, week
      order by count desc) as res
group by week;

-- srednia ilosc negatywnych komentarzy per tweet per miesiac
select avg(count), month
from (select count(*) as count, date_trunc('month', t.created_at) as month
      from tweet t
               join tweet t2 on t.id = t2.reply_to
      where t.type = 1
        and t2.type = 2
        and t2.sentiment_compound <= -0.05
      group by t.id, month
      order by count desc) as res
group by month;