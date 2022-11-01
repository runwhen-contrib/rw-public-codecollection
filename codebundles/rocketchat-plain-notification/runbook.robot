*** Settings ***
Documentation     Send a message to an RocketChat channel.
Library           RW.Core
Library           RW.Rocketchat

*** Tasks ***
Send Notification To Channel On Rocketchat Server
    Log    Importing secrets...
    ${secret}=    Import Secret    rocket-user
    ${rocket_user}=    Set Variable    ${secret.value}
    ${secret}=    Import Secret    rocket-pass
    ${rocket_pass}=    Set Variable    ${secret.value}
    ${secret}=    Import Secret    rocket-server
    ${rocket_server}=    Set Variable    ${secret.value}
    RW.Core.Import User Variable    MSG
    RW.Core.Import User Variable    CHANNEL
    ${rsp}=    RW.Rocketchat.Send Message    ${MSG}    ${CHANNEL}    ${rocket_user}    ${rocket_pass}    ${rocket_server}
    RW.Core.Debug Log    Rocketchat response: ${rsp}
