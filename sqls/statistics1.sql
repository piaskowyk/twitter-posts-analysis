-- userzy którzy pisali same pozytywne tweety
select u.name
from "user" u
where u.id not in (select t.user_id
                   from tweet t
                   where t.type = 1
                     and t.sentiment_compound < 0.05);
