*** Settings ***
Metadata          Author    Jonathan Funk
Metadata          Display Name    GCP Operations Suite Log Query Dashboard URL
Metadata          Supports    GCP,Cloud-Logging,Operations-Suite,stackdriver
Documentation     Generate a link to the GCP Log Explorer.
Force Tags        GCP    Logs    Query    Links
Library           DateTime
Library           RW.GCP.OpsSuite
Library           RW.Core
Suite Setup       Suite Initialization

*** Tasks ***
Get GCP Log Dashboard URL For Given Log Query
    ${query}=    RW.GCP.OpsSuite.Add Time Range
    ...    base_query=${LOG_QUERY}
    ...    within_time=${WITHIN_TIME}
    ${dashboard_url}=    RW.GCP.OpsSuite.Get Logs Dashboard Url
    ...    ${PROJECT_ID}
    ...    ${query}
    RW.Core.Add To Report    GCP Log Explorer Dashboard Link For Query: ${query}
    RW.Core.Add To Report    ${dashboard_url}

*** Keywords ***
Suite Initialization
    RW.Core.Import User Variable    PROJECT_ID
    ...    type=string
    ...    description=The GCP Project ID to scope the API to.
    ...    pattern=\w*
    ...    example=myproject-ID
    RW.Core.Import User Variable    LOG_QUERY
    ...    type=string
    ...    description=The log query used to create the dashboard URL with.
    ...    pattern=\w*
    ...    example=resource.labels.namespace_name:"my-namespace"
    RW.Core.Import User Variable    WITHIN_TIME
    ...    type=string
    ...    pattern=((\d+?)d)?((\d+?)h)?((\d+?)m)?((\d+?)s)?
    ...    description=How far back to retrieve log entries, in the format "1d1h15m", with possible unit values being 'd' representing days, 'h' representing hours, 'm' representing minutes, and 's' representing seconds.
    ...    example=30m
    ...    default=15m
