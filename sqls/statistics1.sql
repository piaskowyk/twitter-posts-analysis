-- ilosc wszystkich tweetów
select count(*) as "Ilość wszystkich tweetów"
from tweet t
where t.type = 1;

-- ilosc wszystkich komentarzy
select count(*) as "Ilość wszystkich komentarzy"
from tweet t
where t.type = 2;

-- ilosc wszystkich cytowań
select count(*) as "Ilość wszystkich cytowań"
from tweet t
where t.type = 3;

-- ilosc wszystkich retweetów
select count(*) as "Ilość wszystkich retweetów"
from retweet;

-- ilosc wszystkich polubień
select sum(t.favorite_count) as "Ilość wszystkich polubień"
from tweet t;

-- srednia ilosc komentarzy per tweet
select avg(t.reply_count) as "Średnia ilość komentarzy na tweet"
from tweet t
where t.type = 1;

-- srednia ilosc retweetow per tweet
select avg(t.retweet_count) "Średnia ilość retweetów na tweet"
from tweet t
where t.type = 1;

-- srednia ilosc polubien per tweet
select avg(t.favorite_count) "Średnia ilość polubień na tweet"
from tweet t
where t.type = 1;

-- srednia ilosc cytowan per tweet
select avg(t.quote_count) "Średnia ilość cytowań na tweet"
from tweet t
where t.type = 1;

-- srednia ilosc komentarzy per tweet na dzien
select avg(t.reply_count) as "Średnia liczba komentarzy na dzień", date_trunc('day', t.created_at) as "Dzień"
from tweet t
where t.type = 1
group by "Dzień"
order by "Dzień" desc;

-- srednia ilosc komentarzy per tweet na tydzien
select avg(t.reply_count) as "Średnia liczba komentarzy na tydzień", date_trunc('week', t.created_at) as "Tydzień"
from tweet t
where t.type = 1
group by "Tydzień"
order by "Tydzień" desc;

-- srednia ilosc komentarzy per tweet na miesiac
select avg(t.reply_count) as "Średnia liczba komentarzy na miesiąc", date_trunc('month', t.created_at) as "Miesiąc"
from tweet t
where t.type = 1
group by "Miesiąc"
order by "Miesiąc" desc;


-- srednia ilosc retweetow per tweet na dzien
select avg(t.retweet_count) as "Średnia liczba retweetow na dzien", date_trunc('day', t.created_at) as "Dzień"
from tweet t
where t.type = 1
group by "Dzień"
order by "Dzień" desc;

-- srednia ilosc retweetow per tweet na tydzien
select avg(t.retweet_count) as "Srednia liczba retweetow na tydzien", date_trunc('week', t.created_at) as "Tydzień"
from tweet t
where t.type = 1
group by "Tydzień"
order by "Tydzień" desc;

-- srednia ilosc retweetow per tweet na miesiac
select avg(t.retweet_count) as "Srednia liczba retweetow na miesiac", date_trunc('month', t.created_at) as "Miesiąc"
from tweet t
where t.type = 1
group by "Miesiąc"
order by "Miesiąc" desc;


-- srednia ilosc polubien per tweet na dzien
select avg(t.favorite_count) as "Srednia liczba polubien na dzien", date_trunc('day', t.created_at) as "Dzień"
from tweet t
where t.type = 1
group by "Dzień"
order by "Dzień" desc;

-- srednia ilosc polubien per tweet na tydzien
select avg(t.favorite_count) as "Srednia liczba polubien na tydzien", date_trunc('week', t.created_at) as "Tydzień"
from tweet t
where t.type = 1
group by "Tydzień"
order by "Tydzień" desc;

-- srednia ilosc polubien per tweet na miesiac
select avg(t.favorite_count) as "Srednia liczba polubien na miesiac", date_trunc('month', t.created_at) as "Miesiąc"
from tweet t
where t.type = 1
group by "Miesiąc"
order by "Miesiąc" desc;


-- srednia ilosc cytowan per tweet na dzien
select avg(t.quote_count) as "Srednia liczba cytowan na dzien", date_trunc('day', t.created_at) as "Dzień"
from tweet t
where t.type = 1
group by "Dzień"
order by "Dzień" desc;

-- srednia ilosc cytowan per tweet na tydzien
select avg(t.quote_count) as "Srednia liczba cytowan na tydzien", date_trunc('week', t.created_at) as "Tydzień"
from tweet t
where t.type = 1
group by "Tydzień"
order by "Tydzień" desc;

-- srednia ilosc cytowan per tweet na miesiac
select avg(t.quote_count) as "Srednia liczba cytowan na miesiac", date_trunc('month', t.created_at) as "Miesiąc"
from tweet t
where t.type = 1
group by "Miesiąc"
order by "Miesiąc" desc;


-- srednia ilosc pozytywnych komentarzy per tweet
select avg(count) as "Średnia liczba pozytywnych komentarzy na tweet"
from (select count(*) as count
      from tweet t
               join tweet t2 on t.id = t2.reply_to
      where t.type = 1
        and t2.type = 2
        and t2.sentiment_compound >= 0.05
      group by t.id
      order by count desc) as counts;

-- srednia ilosc negatywnych komentarzy per tweet
select avg(count) "Średnia liczba negatywnych komentarzy na tweet"
from (select count(*) as count
      from tweet t
               join tweet t2 on t.id = t2.reply_to
      where t.type = 1
        and t2.type = 2
        and t2.sentiment_compound <= -0.05
      group by t.id
      order by count desc) as counts;


-- srednia ilosc pozytywnych komentarzy per tweet per dzien
select avg(count) as "Średnia liczba pozytywnych komentarzy na tweet", day as "Dzień"
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
select avg(count) as "Średnia liczba pozytywnych komentarzy na tweet", week as "Tydzień"
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
select avg(count) as "Średnia liczba pozytywnych komentarzy na tweet", month as "Miesiąc"
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
select avg(count) as "Średnia liczba negatywnych komentarzy na tweet", day as "Dzień"
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
select avg(count) as "Średnia liczba negatywnych komentarzy na tweet", week as "Tydzień"
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
select avg(count) as "Średnia liczba negatywnych komentarzy na tweet", month as "Miesiąc"
from (select count(*) as count, date_trunc('month', t.created_at) as month
      from tweet t
               join tweet t2 on t.id = t2.reply_to
      where t.type = 1
        and t2.type = 2
        and t2.sentiment_compound <= -0.05
      group by t.id, month
      order by count desc) as res
group by month;