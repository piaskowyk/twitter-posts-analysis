from datetime import date, datetime

import psycopg2
import psycopg2.extras
import nltk
import re
from nltk.sentiment.vader import SentimentIntensityAnalyzer


class Database:
    connection = None
    db = None
    sentiment_analyzer = None

    def __init__(self):
        self.connection = psycopg2.connect(
            database="postgres",
            user="postgres",
            password="password",
            host="127.0.0.1",
            port="5432"
        )
        self.db = self.connection.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
        nltk.download('vader_lexicon')
        self.sentiment_analyzer = SentimentIntensityAnalyzer()

    def __del__(self):
        self.db.close()
        self.connection.close()

    def insert_twitter_batch(self, json_data, tweet_type=1):
        for user in json_data['globalObjects']['users'].values():
            self.insert_user(user)
        self.connection.commit()

        for tweet in json_data['globalObjects']['tweets'].values():
            if datetime.strptime(tweet['created_at'], '%a %b %d %H:%M:%S %z %Y').date() < date(2020, 3, 1):
                continue
            tags = None
            if 'hashtags' in tweet['entities']:
                for tag in tweet['entities']['hashtags']:
                    if tags is None:
                        tags = tag['text']
                    else:
                        tags += ',' + tag['text']
            regex = r"\@[\w]*"
            clear_tweet = re.sub(regex, '', tweet['full_text'], 0, re.MULTILINE)
            sentiment_result = self.sentiment_analyzer.polarity_scores(clear_tweet)
            reply_to = tweet.get('in_reply_to_status_id_str', None)
            tweet_id = tweet.get('id', tweet['id_str'])
            user_id = tweet.get('user_id', tweet['user_id_str'])
            fetched_comments = True if reply_to else None
            self.db.execute(
                'INSERT INTO tweet '
                '(id, content, user_id, created_at, tags, sentiment_neg, sentiment_neu, sentiment_pos, '
                'sentiment_compound, retweet_count, favorite_count, reply_count, quote_count, reply_to, '
                'fetched_comments, type) '
                'VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s) ON CONFLICT DO NOTHING',
                (tweet_id, clear_tweet, user_id, tweet['created_at'], tags,
                 sentiment_result['neg'], sentiment_result['neu'],
                 sentiment_result['pos'], sentiment_result['compound'],
                 tweet['retweet_count'], tweet['favorite_count'], tweet['reply_count'], tweet['quote_count'],
                 reply_to, fetched_comments, tweet_type)
            )
        self.connection.commit()

    def insert_user(self, user, user_id_=None):
        if user_id_:
            user_id = user_id_
        else:
            user_id = user.get('id', user.get('id_str', 0))
        self.db.execute(
            'INSERT INTO "user" '
            '(id, name, location, description, followers_count, friends_count, media_count, favourites_count) '
            'VALUES(%s, %s, %s, %s, %s, %s, %s, %s) ON CONFLICT DO NOTHING',
            (user_id, user['name'], user['location'], user['description'], user['followers_count'],
             user['friends_count'], user['media_count'], user['favourites_count'])
        )

    def insert_retweet_batch(self, retweets_json, tweet):
        if 'timeline' not in retweets_json['data']['retweeters_timeline']:
            return
        instructions = retweets_json['data']['retweeters_timeline']['timeline']['instructions']
        if len(instructions) == 0:
            return
        retweets = instructions[0]['entries']
        for retweet in retweets:
            user = retweet['content']['itemContent']['user']
            user_id = user['rest_id']
            self.insert_user(user['legacy'], user_id)
            tweet_id = tweet['id']
            self.db.execute(
                'insert into retweet (user_id, tweet_id) values (%s, %s) ON CONFLICT DO NOTHING',
                (user_id, tweet_id)
            )
        self.connection.commit()

    def exists_tweet(self, tweet_id):
        self.db.execute("SELECT * FROM tweet WHERE id = %s", (tweet_id,))
        return self.db.fetchone() is not None

    def get_tweets_to_comment_fetch(self):
        self.db.execute("SELECT * FROM tweet WHERE fetched_comments is NULL and type = 1")
        return self.db.fetchall()

    def get_tweets_to_retweet_fetch(self):
        self.db.execute("SELECT * FROM tweet WHERE fetched_retweets is NULL and type = 1")
        return self.db.fetchall()

    def get_tweets_to_quote_fetch(self):
        self.db.execute("SELECT * FROM tweet WHERE fetched_quotes is NULL and type = 1")
        return self.db.fetchall()

    def set_as_fetched_comments(self, tweet):
        self.db.execute(f"update tweet set fetched_comments = true where id = {tweet['id']}")
        self.connection.commit()

    def set_as_fetched_retweets(self, tweet):
        self.db.execute(f"update tweet set fetched_retweets = true where id = {tweet['id']}")
        self.connection.commit()

    def set_as_fetched_quotes(self, tweet):
        self.db.execute(f"update tweet set fetched_quotes = true where id = {tweet['id']}")
        self.connection.commit()

    def get_last_date(self):
        self.db.execute('select * from "cursor" c order by c."date" desc limit 1')
        return self.db.fetchone()

    def get_cursors(self):
        self.db.execute('select * from "cursor" c order by c."count" asc')
        return self.db.fetchall()

    def create_cursor(self, date):
        self.db.execute('insert into "cursor" ("date") values (%s) ON CONFLICT DO NOTHING ', [date])
        self.connection.commit()

    def set_cursor(self, date, cursor, count):
        self.db.execute('update "cursor" set "cursor" = %s, "count" = %s where "date" = %s', [cursor, count, date])
        self.connection.commit()
