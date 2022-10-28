*** Settings ***
Documentation     Runbook to send a message to an MS Teams channel.
Library           RW.Core
Library           RW.MSTeams
#TODO: Refactor for new platform use

*** Tasks ***
Send a Message to an MS Teams Channel
    Import User Variable    MSTEAMS_ALERTS_CHANNEL_URL
    RW.MSTeams.Send Message    Red alert!!!    url=${MSTEAMS_ALERTS_CHANNEL_URL}
