*** Settings ***
Library           DateTime
Library           OperatingSystem
Library           RW.GCP.OpsSuite
Library           RW.Utils
Suite Setup       Suite Initialization

*** Variables ***
${SECONDS_IN_PAST}    3600

*** Tasks ***
Running GCE Logging Query And Pushing Result Count Metric
    RW.GCP.OpsSuite.Authenticate    ${GCP_CREDENTIALS}
    ${1hour_ago}=    Get Current Date    increment=-${SECONDS_IN_PAST}s    result_format=%Y-%m-%dT%H:%M:%SZ
    ${now}=    Get Current Date    result_format=%Y-%m-%dT%H:%M:%SZ
    ${time_range}=    Set Variable    AND timestamp > "${1hour_ago}" AND timestamp < "${now}"
    ${rsp}=    RW.GCP.OpsSuite.Get Gce Logs    ${GCP_PROJECT_ID}    ${GCP_LOG_QUERY} ${time_range}
    ${result_dict}=    RW.Utils.From Json    ${rsp}
    ${metric}=    Evaluate    len($result_dict)

Running GCE Logging Query And Fetching Log Explorer Link
    RW.GCP.OpsSuite.Authenticate    ${GCP_CREDENTIALS}
    ${1hour_ago}=    Get Current Date    increment=-${SECONDS_IN_PAST}s    result_format=%Y-%m-%dT%H:%M:%SZ
    ${now}=    Get Current Date    result_format=%Y-%m-%dT%H:%M:%SZ
    ${time_range}=    Set Variable    AND timestamp > "${1hour_ago}" AND timestamp < "${now}"
    ${rsp}=    RW.GCP.OpsSuite.Get Gce Logs    ${GCP_PROJECT_ID}    ${GCP_LOG_QUERY} ${time_range}
    ${result_dict}=    RW.Utils.From Json    ${rsp}
    ${rsp}=    Get Logs Dashboard Url
    ...    ${GCP_PROJECT_ID}
    ...    ${GCP_LOG_QUERY} ${time_range}
    Log    ${rsp}

Running GCE Logging Query Using Implicit Time
    RW.GCP.OpsSuite.Authenticate    ${GCP_CREDENTIALS}
    ${query}=    RW.GCP.OpsSuite.Add Time Range
    ...    base_query=${GCP_LOG_QUERY}
    ...    within_time=15m
    ${rsp}=    RW.GCP.OpsSuite.Get Gce Logs
    ...    project_name=${GCP_PROJECT_ID}
    ...    log_filter=${query}
    ...    gcp_credentials=${GCP_CREDENTIALS}
    ${rsp}=    RW.GCP.OpsSuite.Get Logs Dashboard Url
    ...    project_id=${GCP_PROJECT_ID}
    ...    gcloud_filter=${query}

Running GCE Metric Query And Pushing Result Count Metric
    RW.GCP.OpsSuite.Authenticate    ${GCP_CREDENTIALS}
    ${metric}=    RW.GCP.OpsSuite.Metric Query
    ...    project_name=${GCP_PROJECT_ID}
    ...    mql_statement=${GCP_METRIC_QUERY}
    ...    gcp_credentials=${GCP_CREDENTIALS}

Running GCE Metric Query With Unified Results
    RW.GCP.OpsSuite.Authenticate    ${GCP_CREDENTIALS}
    ${metric}=    RW.GCP.OpsSuite.Metric Query    ${GCP_PROJECT_ID}    ${GCP_METRIC_QUERY2}
    Log    ${metric}

Running GCE Metric Query With New Interface
    ${metric}=    RW.GCP.OpsSuite.Metric Query
    ...    project_name=${GCP_PROJECT_ID}
    ...    mql_statement=${GCP_METRIC_QUERY2}
    ...    gcp_credentials=${GCP_CREDENTIALS}

*** Keywords ***
Suite Initialization
    Set Suite Variable    ${GCP_AUTH_PATH}    %{GCP_AUTH_PATH}
    ${auth}=    Get File    ${GCP_AUTH_PATH}
    Set Suite Variable    ${GCP_PROJECT_ID}    %{GCP_PROJECT_ID}
    Set Suite Variable    ${GCP_LOG_QUERY}    %{GCP_LOG_QUERY}
    Set Suite Variable    ${GCP_METRIC_QUERY}    %{GCP_METRIC_QUERY}
    Set Suite Variable    ${GCP_METRIC_QUERY2}    %{GCP_METRIC_QUERY2}
    ${GCP_CREDENTIALS}=    Evaluate    RW.platform.Secret("gcp_credentials", """${auth}""")
    Set Suite Variable    ${GCP_CREDENTIALS}    ${GCP_CREDENTIALS}
