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
    scroll_pointer = None
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

    def __init__(self):
        self.config_file = open("config.json", "r")
        self.config = json.loads(self.config_file.read())
        self.config_file.close()
        self.config_file = open("config.json", "w")
        self.database = Database()

    def __del__(self):
        self.config_file.close()

    def make_request(self):
        if self.scroll_pointer:
            self.params['cursor'] = self.scroll_pointer
        response = requests.get(
            "https://twitter.com/i/api/2/search/adaptive.json",
            params=self.params,
            headers={
                "authorization": AUTHORIZATION,
                "x-csrf-token": CRSF_TOKEN,
                "cookie": f'auth_token={COOKIES_AUTH_TOKEN}; ct0={COOKIES_CT0};'
            },
        )
        json_data = response.json()
        self.set_scroll_cursor(json_data)
        return json_data

    def set_scroll_cursor(self, json_data):
        if len(json_data['timeline']['instructions']) > 2:
            self.scroll_pointer = json_data['timeline']['instructions'][3]['replaceEntry']['entry']['content']['operation']['cursor'][
                'value']
        else:
            entities_ = json_data['timeline']['instructions'][0]['addEntries']['entries']
            self.scroll_pointer = entities_[len(entities_) - 1]['content']['operation']['cursor']['value']
        self.update_config()

    def update_config(self):
        self.config_file.seek(0)
        self.config['scroll_pointer'] = self.scroll_pointer
        self.config_file.write(json.dumps(self.config))

    def get_latest(self):
        print("[start] get_latest")
        self.scroll_pointer = None
        while True:
            json_data = self.make_request()
            self.database.insert_twitter_batch(json_data)
            tweets = list(json_data['globalObjects']['tweets'].values())
            last_tweet = tweets[len(tweets) - 1]
            print("[start] progress")
            if self.database.exists_tweet(last_tweet[id]):
                print("[finish] get_latest")
                return
            time.sleep(self.interval)

    def get_historical(self, count=None):
        print("[start] get_historical")
        self.scroll_pointer = self.config['scroll_pointer']
        if count is not None:
            for i in range(count):
                self.database.insert_twitter_batch(self.make_request())
                print("[progress] get_historical")
                time.sleep(self.interval)
        else:
            while True:
                self.database.insert_twitter_batch(self.make_request())
                print("[progress] get_historical")
                time.sleep(self.interval)
        print("[finish] get_historical")
