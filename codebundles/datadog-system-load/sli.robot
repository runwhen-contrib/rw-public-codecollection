*** Settings ***
Documentation     Check Datadog system.load metric
Metadata          Name    datadog-system-load
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
#    ${result} =    RW.Datadog.Create Event    Test title X    Test body X    version:21    verbose=true
#    Push Metric    ${res.ok}    descr=${SERVICE_DESCR}
#    ...    status_code=${res.status_code}
#    ...    cluster_name=${res.cluster_name}
#    ...    sealed=${res.sealed}
#    ...    standby=${res.standby}
