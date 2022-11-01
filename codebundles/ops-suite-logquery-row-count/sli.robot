*** Settings ***
Documentation     DEPRECATED
Library           OperatingSystem
Library           Collections
Library           DateTime
Library           RW.Core
Library           RW.Utils.RWUtils
Library           RW.GCP.OpsSuite

*** Tasks ***
Running GCE Logging Query And Pushing Result Count Metric
    Log    Importing secrets...
    ${secret}=    Import Secret    opsuite-sa
    ${opssuite_sa_creds}=    Set Variable    ${secret.value}
    Log    Importing config variables...
    RW.Core.Import User Variable    PROJECT_ID
    RW.Core.Import User Variable    LOG_QUERY
    RW.Core.Import User Variable    SECONDS_IN_PAST
    Log    Executing client query
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
