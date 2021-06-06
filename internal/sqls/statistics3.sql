-- userzy którzy pisali same pozytywne tweety
select u.name as "Użytkownicy piszący same pozytywne tweety"
from "user" u
where u.id not in (select t.user_id
                   from tweet t
                   where t.type = 1
                     and t.sentiment_compound < 0.05);

-- userzy którzy pisali same pozytywne komentarze
select u.name as "Użytkownicy piszący same pozytywne komentarze"
from "user" u
where u.id not in (select t.user_id
                   from tweet t
                   where t.type = 2
                     and t.sentiment_compound < 0.05);

-- userzy którzy pisali same negatywne tweety
select u.name as "Użytkownicy piszący same negatywne tweety"
from "user" u
where u.id not in (select t.user_id
                   from tweet t
                   where t.type = 1
                     and t.sentiment_compound > 0.05);

-- userzy którzy pisali same negatywne komentarze
select u.name as "Użytkownicy piszący same negatywne komentarze"
from "user" u
where u.id not in (select t.user_id
                   from tweet t
                   where t.type = 2
                     and t.sentiment_compound > 0.05);
