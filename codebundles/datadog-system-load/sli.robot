*** Settings ***
Documentation     Retrieve a DataDog instance's "System Load" metric
Metadata          Display Name    Datadog System Load
Metadata          Supports    datadog
Metadata          Type    SLI
Metadata          Author    Vui Le
Force Tags        datadog    load    system
Library           RW.Core
Library           RW.Datadog
#TODO: Refactor for new platform use

*** Tasks ***
Check Datadog System Load
    Import User Variable    DATADOG_API_KEY
    Import User Variable    DATADOG_APP_KEY
    Import User Variable    SERVICE_DESCR
    ${result} =    RW.Datadog.Get Metrics    avg:system.load.1{host:my-minion1}    60    verbose=true
