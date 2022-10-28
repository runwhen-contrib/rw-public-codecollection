*** Settings ***
Library           RW.Chat
Suite Setup       Suite Initialization

*** Variables ***
${CHAT_MESSAGE}    Chat says hello!

*** Tasks ***
Send Hello World With Bus To Google Chat
    ${rsp}=    RW.Chat.Send Message
    ...    include_reports=No
    ...    chat_provider=GoogleChat
    ...    webhook_url=${GCP_CHAT_WEBHOOK}
    ...    message=${CHAT_MESSAGE}

Send Hello World With Bus To Slack
    ${rsp}=    RW.Chat.Send Message
    ...    include_reports=No
    ...    chat_provider=Slack
    ...    channel=${SLACK_CHANNEL}
    ...    token=${SLACK_TOKEN}
    ...    message=${CHAT_MESSAGE}

Send Hello World With Bus To RocketChat
    ${rsp}=    RW.Chat.Send Message
    ...    include_reports=No
    ...    chat_provider=RocketChat
    ...    webhook_url=${ROCKETCHAT_WEBHOOK}
    ...    message=${ROCKETCHAT_TEXT}

Send Report To RocketChat
    ${rsp}=    RW.Chat.Send Message
    ...    include_reports=Yes
    ...    include_runsession_link=Yes
    ...    chat_provider=RocketChat
    ...    webhook_url=${ROCKETCHAT_WEBHOOK}
    ...    message=${ROCKETCHAT_TEXT}

Send Report To Slack
    ${rsp}=    RW.Chat.Send Message
    ...    include_runsession_link=Yes
    ...    include_reports=Yes
    ...    chat_provider=Slack
    ...    channel=${SLACK_CHANNEL}
    ...    token=${SLACK_TOKEN}
    ...    message=${CHAT_MESSAGE}

*** Keywords ***
Suite Initialization
    Set Suite Variable    ${GCP_CHAT_WEBHOOK}    %{GCP_CHAT_WEBHOOK}
    Set Suite Variable    ${SLACK_TOKEN}    %{SLACK_TOKEN}
    Set Suite Variable    ${SLACK_CHANNEL}    %{SLACK_CHANNEL}
    Set Suite Variable    ${ROCKETCHAT_WEBHOOK}    %{ROCKETCHAT_WEBHOOK}
    Set Suite Variable    ${ROCKETCHAT_ALIAS}    %{ROCKETCHAT_ALIAS}
    Set Suite Variable    ${ROCKETCHAT_TEXT}    %{ROCKETCHAT_TEXT}
