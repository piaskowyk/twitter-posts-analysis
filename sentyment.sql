-- tweety z największą ilością pozytywnych komentarzy
select count(t.id), t.*
from tweet t
join tweet c on c.reply_to = t.id
where 
	t.sentiment_compound >= 0.05 
	and t.reply_count > 100
	and t."type" = 1
	and c."type" = 2
group by t.id
order by count(t.id) desc
limit 10;

-- tweety z największą ilością negatywnych komentarzy
select count(t.id), t.*
from tweet t
join tweet c on c.reply_to = t.id
where 
	t.sentiment_compound <= -0.05 
	and t.reply_count > 100
	and t."type" = 1
	and c."type" = 2
group by t.id
order by count(t.id) desc
limit 10;

-- sentyment tweetów czasie dwa tygodnie przed i po wybranej dacie i pogrupowane per dzień
select date(t.created_at), count(t.id), avg(t.sentiment_compound) 
from tweet t 
where 
	t."type" = 1
	and t.created_at between date('2020-03-13') - interval '14' day and date('2020-03-13') + interval '14' day
group by date(t.created_at);

-- sentyment komentarzy czasie z kubełkiem tydzień/miesiąc
select avg(t.sentiment_compound), date_trunc('week', t.created_at) as week
from tweet t
where t.type = 1
group by week
order by week desc;

select avg(t.sentiment_compound), date_trunc('month', t.created_at) as week
from tweet t
where t.type = 1
group by week
order by week desc;

-- ile pozytywnych tweetów w wybranych okresach z kubełkiem dzień/tydzień/miesiąc
select count(t.id), date_trunc('week', t.created_at) as week
from tweet t
where 
	t.type = 1
	and t.sentiment_compound >= 0.05
	and t.created_at between date('2020-03-01') and date('2020-06-01')
group by week
order by week desc;

-- ile neutralnych tweetów w wybranych okresach z kubełkiem dzień/tydzień/miesiąc
select count(t.id), date_trunc('week', t.created_at) as week
from tweet t
where 
	t.type = 1
	and t.sentiment_compound < 0.05
	and t.sentiment_compound > -0.05
	and t.created_at between date('2020-03-01') and date('2020-06-01')
group by week
order by week desc;

-- ile negatywnych tweetów w wybranych okresach z kubełkiem dzień/tydzień/miesiąc
select count(t.id), date_trunc('week', t.created_at) as week
from tweet t
where 
	t.type = 1
	and t.sentiment_compound <= -0.05
	and t.created_at between date('2020-03-01') and date('2020-06-01')
group by week
order by week desc;

-- ile pozytywnych komentarzy w wybranych okresach z kubełkiem dzień/tydzień/miesiąc
select count(t.id), date_trunc('week', t.created_at) as week
from tweet t
where 
	t.type = 2
	and t.sentiment_compound >= 0.05
	and t.created_at between date('2020-03-01') and date('2020-06-01')
group by week
order by week desc;

-- ile neutralnych komentarzy w wybranych okresach z kubełkiem dzień/tydzień/miesiąc
select count(t.id), date_trunc('week', t.created_at) as week
from tweet t
where 
	t.type = 2
	and t.sentiment_compound < 0.05
	and t.sentiment_compound > -0.05
	and t.created_at between date('2020-03-01') and date('2020-06-01')
group by week
order by week desc;

-- ile negatywnych komentarzy w wybranych okresach z kubełkiem dzień/tydzień/miesiąc
select count(t.id), date_trunc('week', t.created_at) as week
from tweet t
where 
	t.type = 2
	and t.sentiment_compound <= -0.05
	and t.created_at between date('2020-03-01') and date('2020-06-01')
group by week
order by week desc;

-- ile tweetów w wybranych okresach z kubełkiem dzień/tydzień/miesiąc
select count(t.id), date_trunc('week', t.created_at) as week
from tweet t
where 
	t.type = 1
	and t.created_at between date('2020-03-01') and date('2020-06-01')
group by week
order by week desc;

-- ile komentarzy w wybranych okresach z kubełkiem dzień/tydzień/miesiąc
select count(t.id), date_trunc('week', t.created_at) as week
from tweet t
where 
	t.type = 2
	and t.created_at between date('2020-03-01') and date('2020-06-01')
group by week
order by week desc;