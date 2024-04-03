*** Settings ***
Documentation     Send a message to an MS Teams channel.
Metadata          Display Name    Microsoft Teams Send Message
Metadata          Supports    Microsoft,MS-TEAMS 
Metadata          Author        Vui Lee
Library           RW.Core
Library           RW.MSTeams
#TODO: Refactor for new platform use

*** Tasks ***
Send a Message to an MS Teams Channel
    Import User Variable    MSTEAMS_ALERTS_CHANNEL_URL
    RW.MSTeams.Send Message    Red alert!!!    url=${MSTEAMS_ALERTS_CHANNEL_URL}
