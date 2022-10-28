*** Settings ***
Metadata          Author    Jonathan Funk
Documentation     An SLI which periodically runs the Google Log Query against the Log Explorer Query API
...               and retrieves the number of results as the metric to push.
Force Tags        GCP    OpsSuite    Query    Logs
Library           OperatingSystem
Library           Collections
Library           DateTime
Library           RW.Core
Library           RW.Utils.RWUtils
Library           RW.GCP.OpsSuite

*** Tasks ***
Running GCE Logging Query And Pushing Result Count Metric
    Log    Importing secrets...
    ${secret}=    Import Secret    ops-suite-sa
    ${opssuite_sa_creds}=    Set Variable    ${secret.value}
    Log    Importing config variables...
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
    RW.GCP.OpsSuite.Authenticate    ${opssuite_sa_creds}
    # open this to config in the future
    ${1hour_ago}=    Get Current Date    increment=-${SECONDS_IN_PAST}s    result_format=%Y-%m-%dT%H:%M:%SZ
    ${now}=    Get Current Date    result_format=%Y-%m-%dT%H:%M:%SZ
    ${time_range}=    Set Variable    AND timestamp > "${1hour_ago}" AND timestamp < "${now}"
    ${rsp}=    RW.GCP.OpsSuite.Get Gce Logs    ${PROJECT_ID}    ${LOG_QUERY} ${time_range}
    ${result_dict}=    RW.Utils.RWUtils.From Json    ${rsp}
    ${result_count}=    Evaluate    len($result_dict)
    Log    Time range: ${time_range}
    Log    Query count: ${result_count}
    RW.Core.Push Metric    ${result_count}
