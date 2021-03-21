import psycopg2


class Database:
    connection = None
    db = None

    def __init__(self):
        self.connection = psycopg2.connect(
            database="postgres",
            user="postgres",
            password="password",
            host="127.0.0.1",
            port="5432"
        )
        self.db = self.connection.cursor()

    def __del__(self):
        self.db.close()
        self.connection.close()

    def insert_twitter_batch(self, json_data):
        for user in json_data['globalObjects']['users'].values():
            self.db.execute(
                'INSERT INTO "user" '
                '(id, name, location, description, followers_count) '
                'VALUES(%s, %s, %s, %s, %s) ON CONFLICT DO NOTHING',
                (user['id'], user['name'], user['location'], user['description'], user['followers_count'])
            )
        self.connection.commit()

        for tweet in json_data['globalObjects']['tweets'].values():
            tags = None
            for tag in tweet['entities']['hashtags']:
                if tags is None:
                    tags = tag['text']
                else:
                    tags += ',' + tag['text']
            self.db.execute(
                'INSERT INTO tweet '
                '(id, content, user_id, created_at, tags) '
                'VALUES (%s, %s, %s, %s, %s) ON CONFLICT DO NOTHING',
                (tweet['id'], tweet['full_text'], tweet['user_id'], tweet['created_at'], tags)
            )
        self.connection.commit()

    def exists_tweet(self, tweet_id):
        self.db.execute("SELECT * FROM tweet WHERE id = %s", (tweet_id,))
        return self.db.fetchone() is not None
