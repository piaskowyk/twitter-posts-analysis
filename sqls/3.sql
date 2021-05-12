-- Ilość tweetów jak się zmieniała w czasie:
-- wybrane dwa tygodnie przed i po wybranej dacie i pogrupowane per dzień

-- 13.03.2020
select count(*) as "liczba tweetów", date(created_at) as "dzień"
from root.public.tweet
group by date(created_at)
having date(created_at) >= date('02.28.2020')
   and date(created_at) <= date('03.27.2020');

-- 01.04.2020
select count(*) as "liczba tweetów", date(created_at) as "dzień"
from root.public.tweet
group by date(created_at)
having date(created_at) >= date('03.18.2020')
   and date(created_at) <= date('04.15.2020');

-- 02.10.2020
select count(*) as "liczba tweetów", date(created_at) as "dzień"
from root.public.tweet
group by date(created_at)
having date(created_at) >= date('09.18.2020')
   and date(created_at) <= date('10.16.2020');

-- 14.12.2020
select count(*) as "liczba tweetów", date(created_at) as "dzień"
from root.public.tweet
group by date(created_at)
having date(created_at) >= date('11.30.2020')
   and date(created_at) <= date('12.28.2020');

-- 02.01.2021
select count(*) as "liczba tweetów", date(created_at) as "dzień"
from root.public.tweet
group by date(created_at)
having date(created_at) >= date('12.19.2020')
   and date(created_at) <= date('01.16.2021');

-- 20.01.2021
select count(*) as "liczba tweetów", date(created_at) as "dzień"
from root.public.tweet
group by date(created_at)
having date(created_at) >= date('01.06.2021')
   and date(created_at) <= date('02.03.2021');

-- Ilość tweetów jak się zmieniała w czasie:
-- pogrupowane per miesiąc
select count(*) as "liczba tweetów", date_part('month', created_at) as miesiac, date_part('year', created_at) as rok
from root.public.tweet
group by date_part('month', created_at), date_part('year', created_at)
order by date_part('year', created_at), date_part('month', created_at);