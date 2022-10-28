*** Settings ***
Metadata          Author    Jonathan Funk
Documentation     A taskset which generates a link to the GCP Log Explorer
Force Tags        GCP    Logs    Query    Links
Library           DateTime
Library           RW.GCP.OpsSuite
Library           RW.Core
Suite Setup       Suite Initialization

*** Tasks ***
Get GCP Log Dashboard URL For Given Log Query
    RW.GCP.OpsSuite.Authenticate    ${OPS_SUITE_SA}
    ${1hour_ago}=    Get Current Date    increment=-${SECONDS_IN_PAST}s    result_format=%Y-%m-%dT%H:%M:%SZ
    ${now}=    Get Current Date    result_format=%Y-%m-%dT%H:%M:%SZ
    ${time_range}=    Set Variable    AND timestamp > "${1hour_ago}" AND timestamp < "${now}"
    ${dashboard_url}=    RW.GCP.OpsSuite.Get Logs Dashboard Url
    ...    ${PROJECT_ID}
    ...    ${LOG_QUERY} ${time_range}
    Log    ${dashboard_url}
    RW.Core.Add To Report    GCP Log Explorer Dashboard Link For Query: ${LOG_QUERY} ${time_range}
    RW.Core.Add To Report    ${dashboard_url}

*** Keywords ***
Suite Initialization
    ${secret}=    Import Secret    ops-suite-sa
    ${OPS_SUITE_SA}=    Set Variable    ${secret.value}
    RW.Core.Import User Variable    PROJECT_ID
    ...    type=string
    ...    description=The GCP Project ID to scope the API to.
    ...    pattern=\w*
    ...    example=myproject-ID
    RW.Core.Import User Variable    LOG_QUERY
    ...    type=string
    ...    description=The number of seconds of history to consider for query results.
    ...    pattern=\w*
    ...    example=resource.labels.namespace_name:"my-namespace"
    RW.Core.Import User Variable    SECONDS_IN_PAST
    ...    type=string
    ...    description=The number of seconds of history to consider for query results.
    ...    pattern="^[0-9]*$"
    ...    example=600
    Set Suite Variable    ${OPS_SUITE_SA}    ${OPS_SUITE_SA}
    Set Suite Variable    ${PROJECT_ID}    ${PROJECT_ID}
    Set Suite Variable    ${LOG_QUERY}    ${LOG_QUERY}
    Set Suite Variable    ${SECONDS_IN_PAST}    ${SECONDS_IN_PAST}
