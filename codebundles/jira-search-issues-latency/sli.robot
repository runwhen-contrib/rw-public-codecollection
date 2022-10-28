*** Settings ***
Documentation     Check Jira latency when searching issues by current user.
Metadata          Name    jira-search-issues-latency
Metadata          Type    SLI
Metadata          Author    Vui Le
Force Tags        jira    latency
Library           RW.Core
Library           RW.Jira
#TODO: Refactor for new platform use

*** Tasks ***
Search Jira Issues By Current User
    Import User Variable    SERVICE_DESCR
    Import User Variable    JIRA_URL
    Import User Variable    JIRA_USER
    Import User Variable    JIRA_USER_TOKEN
    Connect to Jira    server=${JIRA_URL}    user=${JIRA_USER}    token=${JIRA_USER_TOKEN}
    ${res} =    Search Issues
    Log    ${res}
    Push Metric    ${10}    descr=${SERVICE_DESCR}
