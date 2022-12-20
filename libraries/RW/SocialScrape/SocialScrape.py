# Inspired from https://github.com/MartinBeckUT/TwitterScraper/blob/master/snscrape/python-wrapper/snscrape-python-wrapper.py
# # Medium Article Follow-Along: https://medium.com/better-programming/how-to-scrape-tweets-with-snscrape-90124ed006af
"""
SocialScrape keyword library
Based on snscrape https://github.com/JustAnotherArchivist/snscrape
 
Scope: Global
"""

import requests
import urllib
import json
import dateutil.parser

from datetime import timedelta, date
import datetime
from RW import platform
import snscrape.modules.twitter as sntwitter
import pandas as pd

class SocialScrape: 
    """
    Twitter Scraper keyword library
    Uses https://github.com/JustAnotherArchivist/snscrape
    """

    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    @staticmethod
    def twitter_scrape_handle(handle: str = None, maxTweets: int = 5, max_tweet_age: int = 365, min_tweet_age: int = 0):
        """
        Scrapes a specific twitter handle and delivers a list of tweets. 
        E.g. `[[datetime.datetime(2022, 11, 9, 15, 22, 29, tzinfo=datetime.timezone.utc), 1590364208201633793, 'The incident has now been resolved. https://t.co/H0SiNoKzw8', 'GitBookStatus']`
        
        The search range is provided in days and must be provided. The maximum amout of tweets to fetch must also be provided. 
        """

        latest_tweets = [] 
        
        ## Set todays date and calculate the date range for the search query
        today = date.today()
        current_date = today.strftime("%Y-%m-%d")
        start_range = datetime.datetime.strptime(current_date,'%Y-%m-%d').date()-timedelta(days=max_tweet_age)
        end_range = datetime.datetime.strptime(current_date,'%Y-%m-%d').date()-timedelta(days=min_tweet_age)

        # Using TwitterSearchScraper to scrape data 
        for x,tweet in enumerate(sntwitter.TwitterSearchScraper(f'from:{handle} since:{start_range} until:{end_range}').get_items()):
            if x>maxTweets:
                break
            latest_tweets.append([tweet.date, tweet.id, tweet.content, tweet.user.username])

        # Format list
        formatted_tweets = pd.DataFrame(latest_tweets, columns=['Datetime', 'Tweet Id', 'Text', 'Username'])
        
        return formatted_tweets
