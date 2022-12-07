*** Settings ***
Library           RW.Discord
Suite Setup       Suite Initialization

*** Tasks ***
Send Discord Message
    ${rsp}=    RW.Discord.Send Message    ${DISCORD_WEBHOOK_URL}    ${DISCORD_MESSAGE}
    Log    ${rsp}

*** Keywords ***
Suite Initialization
    Set Suite Variable    ${DISCORD_WEBHOOK_URL}    %{DISCORD_WEBHOOK_URL}
    Set Suite Variable    ${DISCORD_MESSAGE}    %{DISCORD_MESSAGE}
