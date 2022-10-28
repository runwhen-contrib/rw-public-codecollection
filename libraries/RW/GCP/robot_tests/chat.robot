*** Settings ***
Library             RW.GCP.Chat

Suite Setup         Suite Initialization
Suite Teardown      Suite Teardown


*** Variables ***
${CHAT_MESSAGE}


*** Tasks ***
Send Hello World1
    Set Suite Variable    ${CHAT_MESSAGE}    ${CHAT_MESSAGE}Hello World1

Send Hello World2
    Set Suite Variable    ${CHAT_MESSAGE}    ${CHAT_MESSAGE}Hello World2


*** Keywords ***
Suite Initialization
    Set Suite Variable    ${GCP_CHAT_WEBHOOK}    %{GCP_CHAT_WEBHOOK}

Suite Teardown
    ${rsp}=    RW.GCP.Chat.Send Message    ${GCP_CHAT_WEBHOOK}    ${CHAT_MESSAGE}
    Log    ${rsp}
