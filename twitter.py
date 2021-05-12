import os
import requests
import time
from database import Database
from dotenv import load_dotenv
from datetime import date, timedelta

load_dotenv()

AUTHORIZATION = os.getenv('AUTHORIZATION', '')
CRSF_TOKEN = os.getenv('CRSF_TOKEN', '')
COOKIES_AUTH_TOKEN = os.getenv('COOKIES_AUTH_TOKEN', '')
COOKIES_CT0 = os.getenv('COOKIES_CT0', '')
query = "covid"


class Twitter:
    config = None
    config_file = None
    mode = 0
    scroll_pointer_comment = None
    scroll_pointer_quote = None
    database: Database = None
    interval = 1  # to avoid block by twitter
    params = {
        "include_profile_interstitial_type": 1,
        "include_blocking": 1,
        "include_blocked_by": 1,
        "include_followed_by": 1,
        "include_want_retweets": 1,
        "include_mute_edge": 1,
        "include_can_dm": 1,
        "include_can_media_tag": 1,
        "skip_status": 1,
        "cards_platform": "Web-12",
        "include_cards": 1,
        "include_ext_alt_text": "true",
        "include_quote_count": "true",
        "include_reply_count": 1,
        "tweet_mode": "extended",
        "include_entities": "true",
        "include_user_entities": "true",
        "include_ext_media_color": "true",
        "include_ext_media_availability": "true",
        "send_error_codes": "true",
        "simple_quoted_tweet": "true",
        "q": query,
        "count": 30,
        "query_source": "typed_query",
        "pc": 1,
        "spelling_corrections": 1,
        "ext": "mediaStats%2ChighlightedLabel",
        "f": "live",
        "tweet_search_mode": "live",
    }
    headers = {}
    start_date = date(2020, 3, 1)

    def __init__(self):
        self.database = Database()
        self.headers = {
            "authorization": AUTHORIZATION,
            "x-csrf-token": CRSF_TOKEN,
            "cookie": f'auth_token={COOKIES_AUTH_TOKEN}; ct0={COOKIES_CT0};'
        }

    def make_request(self, cursor):
        if cursor['cursor']:
            self.params['cursor'] = cursor['cursor']
        if cursor['date']:
            self.params['q'] = query + " until:" + str(cursor['date'])
        response = requests.get(
            "https://twitter.com/i/api/2/search/adaptive.json",
            params=self.params,
            headers=self.headers,
        )
        json_data = response.json()
        self.set_scroll_cursor(json_data, cursor)
        return json_data

    def make_quote_request(self, tweet_id):
        params = self.params.copy()
        if self.scroll_pointer_comment:
            params['cursor'] = self.scroll_pointer_quote
        params['q'] = f'quoted_tweet_id:{tweet_id}'
        response = requests.get(
            "https://twitter.com/i/api/2/search/adaptive.json",
            params=self.params,
            headers=self.headers,
        )
        json_data = response.json()
        is_next = self.set_scroll_cursor(json_data, is_quote=True)
        return json_data, is_next

    def set_scroll_cursor(self, json_data, cursor=None, is_comment=False, is_quote=False):
        if len(json_data['timeline']['instructions']) > 2:
            scroll_pointer = \
                json_data['timeline']['instructions'][3]['replaceEntry']['entry']['content']['operation']['cursor'][
                    'value']
        else:
            if 'addEntries' not in json_data['timeline']['instructions'][0]:
                return False
            entities_ = json_data['timeline']['instructions'][0]['addEntries']['entries']
            if len(entities_) == 1:
                return False
            if 'operation' not in entities_[len(entities_) - 1]['content']:
                return False
            scroll_pointer = entities_[len(entities_) - 1]['content']['operation']['cursor']['value']

        if is_comment:
            self.scroll_pointer_comment = scroll_pointer
        elif is_quote:
            self.scroll_pointer_quote = scroll_pointer
        else:
            cursor['cursor'] = scroll_pointer
            self.update_config(cursor)
        return True

    def update_config(self, cursor):
        self.database.set_cursor(cursor['date'], cursor['cursor'], cursor['count'] + 1)

    def run(self, count=None):
        print("[start] run")
        if count:
            for i in range(count):
                self.step()
        else:
            while True:
                self.step()

    def step(self):
        print("[start] step")
        self.fill_cursors()
        cursors = self.database.get_cursors()
        for cursor in cursors:
            print("[progress] step, " + str(cursor))
            self.database.insert_twitter_batch(self.make_request(cursor), 1)
            time.sleep(self.interval)

    def fill_cursors(self):
        last_cursor_date = self.database.get_last_date()['date']
        today = date.today()
        if last_cursor_date >= today:
            return
        delta = today - last_cursor_date
        for i in range(delta.days + 1):
            day = self.start_date + timedelta(days=i)
            self.database.create_cursor(day)

    def make_comment_request(self, tweet_id):
        params = self.params.copy()
        if self.scroll_pointer_comment:
            params['cursor'] = self.scroll_pointer_comment
        response = requests.get(
            f"https://twitter.com/i/api/2/timeline/conversation/{tweet_id}.json",
            params=params,
            headers=self.headers,
        )
        json_data = response.json()
        if 'errors' in json_data:
            return None, False
        is_next = self.set_scroll_cursor(json_data, is_comment=True)
        return json_data, is_next

    def make_retweet_request(self, tweet_id):
        response = requests.get(
            f"https://twitter.com/i/api/graphql/QajDfWfS6ycxxO8uK271hQ/Retweeters",
            params={
                "variables": '{"tweetId":"' + str(tweet_id) +
                             '","count":1000,"withHighlightedLabel":false,"withTweetQuoteCount":false,'
                             '"includePromotedContent":true,"withTweetResult":false,"withUserResults":false,'
                             '"withNonLegacyCard":true}'
            },
            headers=self.headers,
        )
        json_data = response.json()
        if 'errors' in json_data:
            return None
        return json_data

    def get_comments(self):
        print("[start] get_comments")
        tweets = self.database.get_tweets_to_comment_fetch()
        for tweet in tweets:
            if tweet['reply_count'] == 0:
                self.database.set_as_fetched_comments(tweet)
                continue
            while True:
                json_data, is_next = self.make_comment_request(tweet['id'])
                print("[progress] get_comments")
                time.sleep(self.interval)
                if self.end_of_data(json_data):
                    self.scroll_pointer_comment = None
                    break
                else:
                    self.database.insert_twitter_batch(json_data, 2)

                if not is_next:
                    self.scroll_pointer_comment = None
                    break
            self.database.set_as_fetched_comments(tweet)

    def get_retweets(self):
        print("[start] get_retweets")
        tweets = self.database.get_tweets_to_comment_fetch()
        for tweet in tweets:
            if tweet['retweet_count'] == 0:
                self.database.set_as_fetched_retweets(tweet)
                continue
            json_data = self.make_retweet_request(tweet['id'])
            time.sleep(self.interval)
            print("[progress] get_retweets")
            if not json_data:
                continue
            self.database.insert_retweet_batch(json_data, tweet)
            self.database.set_as_fetched_retweets(tweet)

    def get_quotes(self):
        print("[start] get_quotes")
        tweets = self.database.get_tweets_to_quote_fetch()
        for tweet in tweets:
            print("[progress] tweet")
            print(tweet['quote_count'])
            if tweet['quote_count'] == 0:
                self.database.set_as_fetched_quotes(tweet)
                continue
            index = 0
            last_id, last_id_copy = None, None
            max_quote = 1000 if tweet['quote_count'] > 1000 else tweet['quote_count']
            while True:
                if index > max_quote / 30:
                    break
                index += 1
                json_data, is_next = self.make_quote_request(tweet['id'])
                print("[progress] get_quotes")
                time.sleep(self.interval)
                if self.end_of_data(json_data):
                    self.scroll_pointer_quote = None
                    break
                else:
                    # last_id_copy = last_id
                    # last_id = list(json_data['globalObjects']['tweets'].values())[0]['id']
                    # if last_id_copy == last_id:
                    #     self.scroll_pointer_quote = None
                    #     break
                    self.database.insert_twitter_batch(json_data, 3)

                if not is_next:
                    self.scroll_pointer_quote = None
                    break
            self.database.set_as_fetched_quotes(tweet)

    def end_of_data(self, json_data):
        return not json_data \
                        or 'globalObjects' not in json_data \
                        or 'tweets' not in json_data['globalObjects'] \
                        or not json_data['globalObjects']['tweets'] \
                        or len(list(json_data['globalObjects']['tweets'].values())) <= 1
