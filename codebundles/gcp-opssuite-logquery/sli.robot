*** Settings ***
Metadata          Author    Jonathan Funk
Documentation     Retrieve the number of results of a GCP Log Explorer query.
Force Tags        GCP    OpsSuite    Query    Logs
Library           OperatingSystem
Library           Collections
Library           DateTime
Library           RW.Core
Library           RW.Utils.RWUtils
Library           RW.GCP.OpsSuite
Suite Setup       Suite Initialization

*** Tasks ***
Running GCE Logging Query And Pushing Result Count Metric
    ${query}=    RW.GCP.OpsSuite.Add Time Range
    ...    base_query=${LOG_QUERY}
    ...    within_time=${WITHIN_TIME}
    ${rsp}=    RW.GCP.OpsSuite.Get Gce Logs
    ...    project_name=${PROJECT_ID}
    ...    log_filter=${query}
    ...    gcp_credentials=${ops-suite-sa}
    ${result_dict}=    RW.Utils.RWUtils.From Json    ${rsp}
    ${result_count}=    Evaluate    len($result_dict)
    RW.Core.Push Metric    ${result_count}

*** Keywords ***
Suite Initialization
    RW.Core.Import Secret    ops-suite-sa
    ...    type=string
    ...    description=GCP service account json used to authenticate with GCP APIs.
    ...    pattern=\w*
    ...    example={"type": "service_account","project_id":"myproject-ID", ... super secret stuff ...}
    RW.Core.Import User Variable    PROJECT_ID
    ...    type=string
    ...    description=The GCP Project ID to scope the API to.
    ...    pattern=\w*
    ...    example=myproject-ID
    RW.Core.Import User Variable    LOG_QUERY
    ...    type=string
    ...    description=The log query used to filter results to determine the metric count.
    ...    pattern=\w*
    ...    example=resource.labels.namespace_name:"my-namespace"
    RW.Core.Import User Variable    WITHIN_TIME
    ...    type=string
    ...    pattern=((\d+?)d)?((\d+?)h)?((\d+?)m)?((\d+?)s)?
    ...    description=How far back to retrieve log entries, in the format "1d1h15m", with possible unit values being 'd' representing days, 'h' representing hours, 'm' representing minutes, and 's' representing seconds.
    ...    example=30m
    ...    default=15m
