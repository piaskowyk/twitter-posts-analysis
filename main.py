# import psycopg2
#
# con = psycopg2.connect(database="postgres", user="postgres", password="password", host="127.0.0.1", port="5432")
#
# print("Database opened successfully")

import os
import requests
import json
from dotenv import load_dotenv

load_dotenv()
AUTHORIZATION = os.getenv('AUTHORIZATION', '')
CRSF_TOKEN = os.getenv('CRSF_TOKEN', '')
COOKIES_AUTH_TOKEN = os.getenv('COOKIES_AUTH_TOKEN', '')
COOKIES_CT0 = os.getenv('COOKIES_CT0', '')
query = "covid"


def make_request(scroll_pointer_=None):
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
    if scroll_pointer_:
        params['cursor'] = scroll_pointer_
    return requests.get(
        "https://twitter.com/i/api/2/search/adaptive.json",
        params=params,
        headers={
            "authorization": AUTHORIZATION,
            "x-csrf-token": CRSF_TOKEN,
            "cookie": f'auth_token={COOKIES_AUTH_TOKEN}; ct0={COOKIES_CT0};'
        },
    )


def get_scroll_cursor(json_data_):
    if len(json_data_['timeline']['instructions']) > 2:
        return json_data_['timeline']['instructions'][3]['replaceEntry']['entry']['content']['operation']['cursor']['value']
    else:
        entities_ = json_data_['timeline']['instructions'][0]['addEntries']['entries']
        return entities_[len(entities_) - 1]['content']['operation']['cursor']['value']


json_data = make_request().json()
file = open("json1.json", "w")
file.write(json.dumps(json_data))
file.close()

scroll_pointer = get_scroll_cursor(json_data)
json_data = make_request(scroll_pointer).json()
file = open("json2.json", "w")
file.write(json.dumps(json_data))
file.close()

scroll_pointer = get_scroll_cursor(json_data)
json_data = make_request(scroll_pointer).json()
file = open("json3.json", "w")
file.write(json.dumps(json_data))
file.close()
