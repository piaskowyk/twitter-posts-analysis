import psycopg2
import nltk
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
        self.db = self.connection.cursor()
        nltk.download('vader_lexicon')
        self.sentiment_analyzer = SentimentIntensityAnalyzer()

    def __del__(self):
        self.db.close()
        self.connection.close()

    def insert_twitter_batch(self, json_data):
        for user in json_data['globalObjects']['users'].values():
            user_id = user.get('id', user['id_str'])
            self.db.execute(
                'INSERT INTO "user" '
                '(id, name, location, description, followers_count) '
                'VALUES(%s, %s, %s, %s, %s) ON CONFLICT DO NOTHING',
                (user_id, user['name'], user['location'], user['description'], user['followers_count'])
            )
        self.connection.commit()

        for tweet in json_data['globalObjects']['tweets'].values():
            tags = None
            if 'hashtags' in tweet['entities']:
                for tag in tweet['entities']['hashtags']:
                    if tags is None:
                        tags = tag['text']
                    else:
                        tags += ',' + tag['text']
            sentiment_result = self.sentiment_analyzer.polarity_scores(tweet['full_text'])
            reply_to = tweet.get('in_reply_to_status_id_str', None)
            tweet_id = tweet.get('id', tweet['id_str'])
            user_id = tweet.get('user_id', tweet['user_id_str'])
            self.db.execute(
                'INSERT INTO tweet '
                '(id, content, user_id, created_at, tags, sentiment_neg, sentiment_neu, sentiment_pos, '
                'sentiment_compound, retweet_count, favorite_count, reply_count, quote_count, reply_to) '
                'VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s) ON CONFLICT DO NOTHING',
                (tweet_id, tweet['full_text'], user_id, tweet['created_at'], tags,
                 sentiment_result['neg'], sentiment_result['neu'],
                 sentiment_result['pos'], sentiment_result['compound'],
                 tweet['retweet_count'], tweet['favorite_count'], tweet['reply_count'], tweet['quote_count'], reply_to)
            )
        self.connection.commit()

    def exists_tweet(self, tweet_id):
        self.db.execute("SELECT * FROM tweet WHERE id = %s", (tweet_id,))
        return self.db.fetchone() is not None

    def get_tweets_to_comment_fetch(self):
        self.db.execute("SELECT * FROM tweet WHERE fetched_comments is NULL")
        return self.db.fetchall()
