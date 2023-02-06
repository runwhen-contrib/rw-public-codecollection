*** Settings ***
Metadata          Author    Jonathan Funk
Documentation     Sends a static Discord message via webhook. Contains optional configuration for including runsession info.
Force Tags        Discord    Message    Messaging    Send    Alert    Notify
Library           RW.Core
Library           RW.RunWhen.Papi
Library           RW.Rest
Library           RW.Utils
Suite Setup       Suite Initialization

*** Tasks ***
Send Chat Message
    ${runsession_info}=    RW.RunWhen.Papi.Get Runsession Info
    ...    include_runsession_link=${INCLUDE_RUNSESSION_LINK}
    ...    include_runsession_stdout=${INCLUDE_REPORTS}
    ${msg}=    Catenate    SEPARATOR=\n    ${MESSAGE}    ${runsession_info}
    # we need to json encode just the msg contents to escape any json special characters
    ${msg}=    RW.Utils.To Json    ${msg}
    # discord expects msg contents in the content key
    ${data}=   RW.Utils.From Json    {"content":${msg}}
    ${rsp}=    RW.Rest.Request    url=${webhook_url}    method=POST    json=${data}
    RW.Rest.Handle Response    rsp=${rsp}
    RW.Core.Add To Report    Sent Message: ${msg}
    RW.Core.Add To Report    Response: ${rsp.text}


*** Keywords ***
Suite Initialization
    ${webhook_url}=    Import Secret    webhook_url
    ...    type=string
    ...    description=The webhook url to perform requests against.
    ...    pattern=\w*
    ...    example=https://my-chat-service/v1/webhook/mysecrettoken
    RW.Core.Import User Variable    MESSAGE
    ...    type=string
    ...    description=Your handcrafted message that's always included.
    ...    pattern=\w*
    ...    default=We've detected a workspace event!
    ...    example=We've detected a workspace event!
    RW.Core.Import User Variable    INCLUDE_RUNSESSION_LINK
    ...    type=string
    ...    enum=[YES,NO]
    ...    default=YES
    ...    example=YES
    ...    description=Whether or not the message includes a link to the runsession report on the platform.
    RW.Core.Import User Variable    INCLUDE_REPORTS
    ...    type=string
    ...    enum=[YES,NO]
    ...    default=NO
    ...    example=NO
    ...    description=Whether or not the message includes associated runsession data.
    Set Suite Variable    ${webhook_url}    ${webhook_url}
    Set Suite Variable    ${MESSAGE}    ${MESSAGE}
    Set Suite Variable    ${INCLUDE_RUNSESSION_LINK}    ${INCLUDE_RUNSESSION_LINK}
    Set Suite Variable    ${INCLUDE_REPORTS}    ${INCLUDE_REPORTS}
