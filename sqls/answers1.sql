-- Które tweety mają więcej komentarzy, negatywne czy pozytywne?
select (select sum(t.reply_count)
        from tweet t
        where t.type = 1
          and t.sentiment_compound >= 0.05) -
       (select sum(t.reply_count)
        from tweet t
        where t.type = 1
          and t.sentiment_compound <= -0.05) > 0 as "Czy pozytywne tweety mają więcej komentarzy niz negatywne";

-- Które tweety mają więcej cytowań, negatywne czy pozytywne?
select (select sum(t.quote_count)
        from tweet t
        where t.type = 1
          and t.sentiment_compound >= 0.05) -
       (select sum(t.quote_count)
        from tweet t
        where t.type = 1
          and t.sentiment_compound <= -0.05) > 0 as "Czy pozytywne tweety mają więcej cytowan niz negatywne";

-- Które tweety mają więcej polubien, negatywne czy pozytywne?
select (select sum(t.favorite_count)
        from tweet t
        where t.type = 1
          and t.sentiment_compound >= 0.05) -
       (select sum(t.favorite_count)
        from tweet t
        where t.type = 1
          and t.sentiment_compound <= -0.05) > 0 as "Czy pozytywne tweety mają więcej polubien niz negatywne";

