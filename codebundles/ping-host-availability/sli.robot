*** Settings ***
Documentation     Check availability by pinging host.
Metadata          Name    ping-host-availability
Metadata          Type    SLI
Metadata          Author    Vui Le
Force Tags        ping    availability
Library           RW.Core
#TODO: Refactor for new platform use

*** Tasks ***
Ping host and collect packet lost percentage
    RW.Core.Import User Variable    HOST_NAME
    ${result} =    RW.Core.Ping    ${HOST_NAME}    count=10
    RW.Core.Info Log    ${result["stdout"]}
    RW.Core.Push Metric    ${result["packet_loss_percentage"]}
