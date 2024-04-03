*** Settings ***
Metadata          Author    Shea Stewart
Metadata          Display Name    Twitter Query Handle
Metadata          Supports    twitter 
Documentation     Queries Twitter to fetch tweets within a specified time range for a specific user handle add them to a report.
Force Tags        Twitter    Social   tweet
Suite Setup       Suite Initialization
Library           RW.Core
Library           RW.SocialScrape

*** Keywords ***
Suite Initialization
    RW.Core.Import User Variable    HANDLE
    ...    type=string
    ...    description=The twitter handle to query.
    ...    pattern=\w*
    ...    example=gitbookstatus
    RW.Core.Import User Variable    MAX_TWEETS
    ...    type=int
    ...    description=The number of the latest tweets to scrape.
    ...    example=5
    ...    default=5
    RW.Core.Import User Variable    MAX_TWEET_AGE
    ...    type=int
    ...    description=The maximum age of the tweet in days.
    ...    example=1
    ...    default=1
    RW.Core.Import User Variable    MIN_TWEET_AGE
    ...    type=int
    ...    description=The minimum age of the tweet in days.
    ...    example=0
    ...    default=0
    Set Suite Variable    ${HANDLE}    ${HANDLE}
    Set Suite Variable    ${MAX_TWEETS}    ${MAX_TWEETS}
    Set Suite Variable    ${MAX_TWEET_AGE}    ${MAX_TWEET_AGE}
    Set Suite Variable    ${MIN_TWEET_AGE}    ${MIN_TWEET_AGE}

*** Tasks ***
Query Twitter
    ${rsp}=    RW.SocialScrape.Twitter Scrape Handle    handle=${HANDLE}    maxTweets=${MAX_TWEETS}    max_tweet_age=${MAX_TWEET_AGE}    min_tweet_age=${MIN_TWEET_AGE}
    Log    ${rsp}
    RW.Core.Add Pre To Report    ${rsp}
