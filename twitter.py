import os
import requests
import json
import time
from database import Database
from dotenv import load_dotenv
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
    scroll_pointer_latest = None
    scroll_pointer_historical = None
    scroll_pointer_comment = None
    database: Database = None
    interval = 15  # to avoid block by twitter
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
        "count": 20,
        "query_source": "typed_query",
        "pc": 1,
        "spelling_corrections": 1,
        "ext": "mediaStats%2ChighlightedLabel"
    }
    headers = {}

    def __init__(self):
        self.config_file = open("config.json", "r")
        self.config = json.loads(self.config_file.read())
        self.scroll_pointer_historical = self.config['scroll_pointer_historical']
        self.scroll_pointer_latest = self.config['scroll_pointer_latest']
        self.config_file.close()
        self.config_file = open("config.json", "w")
        self.database = Database()
        self.headers = {
            "authorization": AUTHORIZATION,
            "x-csrf-token": CRSF_TOKEN,
            "cookie": f'auth_token={COOKIES_AUTH_TOKEN}; ct0={COOKIES_CT0};'
        }

    def __del__(self):
        self.update_config()
        self.config_file.close()

    def make_request(self):
        if self.mode == 0 and self.scroll_pointer_historical:
            self.params['cursor'] = self.scroll_pointer_historical
        elif self.mode == 1 and self.scroll_pointer_latest:
            self.params['cursor'] = self.scroll_pointer_latest
        response = requests.get(
            "https://twitter.com/i/api/2/search/adaptive.json",
            params=self.params,
            headers=self.headers,
        )
        json_data = response.json()
        self.set_scroll_cursor(json_data)
        return json_data

    def set_scroll_cursor(self, json_data, is_comment=False):
        if len(json_data['timeline']['instructions']) > 2:
            scroll_pointer = json_data['timeline']['instructions'][3]['replaceEntry']['entry']['content']['operation']['cursor'][
                'value']
        else:
            entities_ = json_data['timeline']['instructions'][0]['addEntries']['entries']
            if len(entities_) == 1:
                return False
            if 'operation' not in entities_[len(entities_) - 1]['content']:
                return False
            scroll_pointer = entities_[len(entities_) - 1]['content']['operation']['cursor']['value']

        if is_comment:
            self.scroll_pointer_comment = scroll_pointer
        elif self.mode == 0:
            self.scroll_pointer_historical = scroll_pointer
            self.update_config()
        elif self.mode == 1:
            self.scroll_pointer_latest = scroll_pointer
            self.update_config()
        return True

    def update_config(self):
        self.config_file.seek(0)
        self.config['scroll_pointer_historical'] = self.scroll_pointer_historical
        self.config['scroll_pointer_latest'] = self.scroll_pointer_latest
        self.config_file.write(json.dumps(self.config))

    def get_latest(self):
        print("[start] get_latest")
        self.mode = 1
        while True:
            json_data = self.make_request()
            tweets = list(json_data['globalObjects']['tweets'].values())
            last_tweet = tweets[len(tweets) - 1]
            print("[start] progress")
            if self.database.exists_tweet(last_tweet['id']):
                print("[finish] get_latest")
                return
            self.database.insert_twitter_batch(json_data)
            time.sleep(self.interval)
            self.get_comments()

    def get_historical(self, count=None):
        print("[start] get_historical")
        self.mode = 0
        if count is not None:
            for i in range(count):
                self.database.insert_twitter_batch(self.make_request())
                print("[progress] get_historical")
                time.sleep(self.interval)
                self.get_comments()
        else:
            while True:
                self.database.insert_twitter_batch(self.make_request())
                print("[progress] get_historical")
                time.sleep(self.interval)
                self.get_comments()
        print("[finish] get_historical")

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
        is_next = self.set_scroll_cursor(json_data, True)
        return json_data, is_next

    def get_comments(self):
        print("[start] get_comments")
        tweets = self.database.get_tweets_to_comment_fetch()
        for tweet in tweets:
            while True:
                json_data, is_next = self.make_comment_request(tweet[0])
                time.sleep(self.interval)
                if not is_next or len(list(json_data['globalObjects']['tweets'].values())) <= 1:
                    self.scroll_pointer_comment = None
                    break
                self.database.insert_twitter_batch(json_data)
                print("[progress] get_comments")
