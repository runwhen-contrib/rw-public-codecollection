
*** Settings ***
Metadata          Author    Jonathan Funk
Documentation     This codebundle provides a list of integrations to chat services like Slack or Discord. With it
...               users can send messages containing links, static content, or runsession report info.
Force Tags        Chat    Slack    Discord    Google    Message    Messaging    Send    Alert    Notify
Library           RW.Core
Library           RW.Chat
Suite Setup       Suite Initialization

*** Tasks ***
Send Chat Message
    ${rsp}=    RW.Chat.Send Message
    ...    chat_provider=${CHAT_PROVIDER}
    ...    include_runsession_link=${INCLUDE_RUNSESSION_LINK}
    ...    include_reports=${INCLUDE_REPORTS}
    ...    channel=${CHAT_CHANNEL}
    ...    token=${OAUTH2_TOKEN}
    ...    webhook_url=${WEBHOOK_URL}
    ...    message=${MESSAGE}

*** Keywords ***
Suite Initialization
    ${secret}=    Import Secret    oauth2_token
    ...    type=string
    ...    description=If the integration uses a oauth2 token, it will reference this secret.
    ...    pattern=\w*
    ...    example=My super secret oauth2 token.
    ${OAUTH2_TOKEN}=    Set Variable    ${secret.value}
    ${secret}=    Import Secret    webhook_url
    ...    type=string
    ...    description=If the integration uses a webhook URL, it will reference this secret.
    ...    pattern=\w*
    ...    example=My webhook URL.
    ${WEBHOOK_URL}=    Set Variable    ${secret.value}
    RW.Core.Import User Variable    CHAT_PROVIDER
    ...    type=string
    ...    enum=[GoogleChat,Slack,Discord,RocketChat,MicrosoftTeams,AlertManager,PagerDuty,OpsGenie]
    ...    description=Determines which chat provider integration to use.
    RW.Core.Import User Variable    MESSAGE
    ...    type=string
    ...    description=Your handcrafted message that's always included.
    ...    pattern=\w*
    ...    default=We detected a workspace event!
    ...    example=We detected a workspace event!
    RW.Core.Import User Variable    INCLUDE_RUNSESSION_LINK
    ...    type=string
    ...    enum=[Yes,No]
    ...    default=Yes
    ...    description=Whether or not the message includes a link to the runsession report on the platform.
    RW.Core.Import User Variable    INCLUDE_REPORTS
    ...    type=string
    ...    enum=[Yes,No]
    ...    default=No
    ...    description=Whether or not the message includes associated runrequest reports.
    RW.Core.Import User Variable
    ...    CHAT_CHANNEL
    ...    type=string
    ...    description=If the chosen chat integration needs a channel, it will reference this value.
    ...    pattern=\w*
    Set Suite Variable    ${OAUTH2_TOKEN}    ${OAUTH2_TOKEN}
    Set Suite Variable    ${WEBHOOK_URL}    ${WEBHOOK_URL}
    Set Suite Variable    ${CHAT_PROVIDER}    ${CHAT_PROVIDER}
    Set Suite Variable    ${MESSAGE}    ${MESSAGE}
    Set Suite Variable    ${INCLUDE_RUNSESSION_LINK}    ${INCLUDE_RUNSESSION_LINK}
    Set Suite Variable    ${INCLUDE_REPORTS}    ${INCLUDE_REPORTS}
    Set Suite Variable    ${CHAT_CHANNEL}    ${CHAT_CHANNEL}
