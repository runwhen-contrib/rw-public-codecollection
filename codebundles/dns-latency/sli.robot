*** Settings ***
Documentation     SLI to check DNS latency for Google Resolver
Metadata          Name    dns-latency
Metadata          Type    SLI
Metadata          Author    Vui Le
Force Tags        dns    latency
Library           RW.Core
Library           RW.DNS
#TODO: Refactor for new platform use

*** Tasks ***
Check DNS latency for Google Resolver
    [Documentation]    Get DNS latency for Google resolver
    RW.Core.Import User Variable    HOSTNAME_TO_RESOLVE
    ${latency_ms} =    RW.DNS.Lookup Latency In Milliseconds
    ...    host=${HOSTNAME_TO_RESOLVE}    nameservers=8.8.8.8
    RW.Core.Debug Log    Latency in milliseconds: ${latency_ms}
    RW.Core.Push Metric    ${latency_ms}
