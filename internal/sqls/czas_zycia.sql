-- średni czas życia tweeta
with time_diffs as (
	select 
		t.id as t_id,
		t."content"as t_content,
		GREATEST(
			(c.created_at::timestamp - t.created_at::timestamp), 
			(q.created_at::timestamp - t.created_at::timestamp)
		) diff
	from tweet t
	left join tweet c on t.id = c.reply_to and c."type" = 2
	left join tweet q on t.id = q.reply_to and q."type" = 3
	where t.reply_count > 100
)
select avg(t.diff) as "sredni czas zycia tweeta"
from time_diffs t 
where t.diff is not null;

-- minimalny czas życia tweeta
with time_diffs as (
	select 
		t.id as t_id,
		u."name" as user_name,
		t."content"as t_content,
		least(
			(c.created_at::timestamp - t.created_at::timestamp), 
			(q.created_at::timestamp - t.created_at::timestamp)
		) diff
	from tweet t
	left join tweet c on t.id = c.reply_to and c."type" = 2
	left join tweet q on t.id = q.reply_to and q."type" = 3
	join "user" u on t.user_id = u.id
	where t.reply_count > 100
)
select distinct t.t_id, t.diff, t.t_content, t.user_name
from time_diffs t
where t.diff is not null
order by t.diff
limit 100;

-- maksymalny czas życia tweeta
with time_diffs as (
	select 
		t.id as t_id,
		u."name" as user_name,
		t."content"as t_content,
		GREATEST(
			(c.created_at::timestamp - t.created_at::timestamp), 
			(q.created_at::timestamp - t.created_at::timestamp)
		) diff
	from tweet t
	left join tweet c on t.id = c.reply_to and c."type" = 2
	left join tweet q on t.id = q.reply_to and q."type" = 3
	join "user" u on t.user_id = u.id
	where t.reply_count > 100
)
select distinct t.t_id, t.diff, t.t_content, t.user_name
from time_diffs t
where t.diff is not null
order by t.diff desc
limit 100;

-- średni czas życia pozytywnych tweetów
with time_diffs as (
	select 
		t.id as t_id,
		t."content"as t_content,
		GREATEST(
			(c.created_at::timestamp - t.created_at::timestamp), 
			(q.created_at::timestamp - t.created_at::timestamp)
		) diff
	from tweet t
	left join tweet c on t.id = c.reply_to and c."type" = 2
	left join tweet q on t.id = q.reply_to and q."type" = 3
	where t.reply_count > 100 and t.sentiment_compound >= 0.05
)
select avg(t.diff)
from time_diffs t
where t.diff is not null;

-- średni czas życia neutralnego tweetów
with time_diffs as (
	select 
		t.id as t_id,
		t."content"as t_content,
		GREATEST(
			(c.created_at::timestamp - t.created_at::timestamp), 
			(q.created_at::timestamp - t.created_at::timestamp)
		) diff
	from tweet t
	left join tweet c on t.id = c.reply_to and c."type" = 2
	left join tweet q on t.id = q.reply_to and q."type" = 3
	where t.reply_count > 100 and t.sentiment_compound > -0.05 and t.sentiment_compound < 0.05
)
select avg(t.diff)
from time_diffs t
where t.diff is not null;

-- średni czas życia negatywnych tweetów
with time_diffs as (
	select 
		t.id as t_id,
		t."content"as t_content,
		GREATEST(
			(c.created_at::timestamp - t.created_at::timestamp), 
			(q.created_at::timestamp - t.created_at::timestamp)
		) diff
	from tweet t
	left join tweet c on t.id = c.reply_to and c."type" = 2
	left join tweet q on t.id = q.reply_to and q."type" = 3
	where t.reply_count > 100 and t.sentiment_compound <= -0.05
)
select avg(t.diff)
from time_diffs t
where t.diff is not null;

-- zmiana czasu życia tweeta w czasie
with time_diffs as (
	select 
		t.id as t_id,
		t."content"as t_content,
		t.created_at,
		GREATEST(
			(c.created_at::timestamp - t.created_at::timestamp), 
			(q.created_at::timestamp - t.created_at::timestamp)
		) diff
	from tweet t
	left join tweet c on t.id = c.reply_to and c."type" = 2
	left join tweet q on t.id = q.reply_to and q."type" = 3
	where t.reply_count > 100
)
select date_trunc('week', t.created_at) as week, avg(t.diff) 
from time_diffs t
where t.diff is not null
group by week;
	

-- zmiana czasu życia pozytywnego tweeta w czasie
with time_diffs as (
	select 
		t.id as t_id,
		t."content"as t_content,
		t.created_at,
		GREATEST(
			(c.created_at::timestamp - t.created_at::timestamp), 
			(q.created_at::timestamp - t.created_at::timestamp)
		) diff
	from tweet t
	left join tweet c on t.id = c.reply_to and c."type" = 2
	left join tweet q on t.id = q.reply_to and q."type" = 3
	where t.reply_count > 100 and t.sentiment_compound >= 0.05
)
select date_trunc('week', t.created_at) as week, avg(t.diff) 
from time_diffs t
where t.diff is not null
group by week;

-- zmiana czasu życia neutralnego tweeta w czasie
with time_diffs as (
	select 
		t.id as t_id,
		t."content"as t_content,
		t.created_at,
		GREATEST(
			(c.created_at::timestamp - t.created_at::timestamp), 
			(q.created_at::timestamp - t.created_at::timestamp)
		) diff
	from tweet t
	left join tweet c on t.id = c.reply_to and c."type" = 2
	left join tweet q on t.id = q.reply_to and q."type" = 3
	where t.reply_count > 100 and t.sentiment_compound > -0.05 and t.sentiment_compound < 0.05
)
select date_trunc('week', t.created_at) as week, avg(t.diff) 
from time_diffs t
where t.diff is not null
group by week;

-- zmiana czasu życia negatywnego tweeta w czasie
with time_diffs as (
	select 
		t.id as t_id,
		t."content"as t_content,
		t.created_at,
		GREATEST(
			(c.created_at::timestamp - t.created_at::timestamp), 
			(q.created_at::timestamp - t.created_at::timestamp)
		) diff
	from tweet t
	left join tweet c on t.id = c.reply_to and c."type" = 2
	left join tweet q on t.id = q.reply_to and q."type" = 3
	where t.reply_count > 100 and t.sentiment_compound <= -0.05
)
select date_trunc('week', t.created_at) as week, avg(t.diff) 
from time_diffs t
where t.diff is not null
group by week;
