*** Settings ***
Documentation     Runbook to send a message to a Discord channel.
Metadata          Name    discord-send-message
Metadata          Type    Runbook
Metadata          Author    Vui Le
Force Tags        discord    alert    message
Library           RW.Core
Library           RW.Discord
#TODO: Refactor for new platform use

*** Tasks ***
Send a Message to a Discord Channel
    Import User Variable    DISCORD_ALERTS_CHANNEL_URL
    RW.Discord.Send Message    Red alert (sent by Discord Bot via Webhook)!!!    url=${DISCORD_ALERTS_CHANNEL_URL}    verbose=True
