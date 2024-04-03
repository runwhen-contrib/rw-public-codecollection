*** Settings ***
Metadata          Author    Jonathan Funk
Metadata          Display Name    Datadog Metric
Metadata          Supports    datadog
Documentation     Fetch the results of a datadog metric timeseries and push the extracted value as an SLI metric.
Force Tags        datadog    metric    query    API
Suite Setup       Suite Initialization
Library           RW.Core
Library           RW.Datadog

*** Keywords ***
Suite Initialization
    ${DATADOG_API_KEY}=    RW.Core.Import Secret    DATADOG_API_KEY
    ...    type=string
    ...    description=The Datadog API key used to authenticate with the API endpoint.
    ...    pattern=\w*
    ...    default=
    ...    example=27437462aebc-myapi-key
    ${DATADOG_APP_KEY}=    RW.Core.Import Secret    DATADOG_APP_KEY
    ...    type=string
    ...    description=The Datadog app key used to uniquely identify the application interacting with the Datadog API endpoint.
    ...    pattern=\w*
    ...    default=
    ...    example=27437462aebc-myapp-key
    ${DATADOG_SITE}=    RW.Core.Import User Variable    DATADOG_SITE
    ...    type=string
    ...    description=Which Datadog zone site to use for requests.
    ...    pattern=\w*
    ...    default=datadoghq.com
    ...    example=us3.datadoghq.com (prepend your zone)
    ${METRIC_QUERY}=    RW.Core.Import User Variable    METRIC_QUERY
    ...    type=string
    ...    description=The Datadog metric query used. See https://docs.datadoghq.com/metrics/advanced-filtering/
    ...    pattern=\w*
    ...    example=max:system.cpu.user{*}
    ...    default=max:system.cpu.user{*}
    ${HISTORY_RANGE}=    RW.Core.Import User Variable    HISTORY_RANGE
    ...    type=string
    ...    pattern=((\d+?)d)?((\d+?)h)?((\d+?)m)?((\d+?)s)?
    ...    description=How much history to fetch for the timeseries, in the format "1d7h10m", with possible unit values being 'd' representing days, 'h' representing hours, 'm' representing minutes, and 's' representing seconds.
    ...    example=1h10m
    ...    default=60s
    ${JSON_PATH}=    RW.Core.Import User Variable    JSON_PATH
    ...    type=string
    ...    description=A json path string that is used to extract data from the response.
    ...    pattern=\w*
    ...    example=series[0].pointlist[-1][1] this means get the newest data point from the first timeseries returned.
    ...    default=series[0].pointlist[-1][1]
    ${NO_RESULT_OVERWRITE}=    RW.Core.Import User Variable    NO_RESULT_OVERWRITE
    ...    type=string
    ...    description=Determine how to handle queries with no result data. Set to Yes to write a metric (specified below) or No to accept the null result. 
    ...    pattern=\w*
    ...    enum=[Yes,No]
    ...    default=No
    ${NO_RESULT_VALUE}=    RW.Core.Import User Variable    NO_RESULT_VALUE
    ...    type=string
    ...    description=Set the metric value that should be stored when no data result is available.
    ...    pattern=\d*
    ...    default=0
    ...    example=0
    Set Suite Variable    ${DATADOG_API_KEY}    ${DATADOG_API_KEY}
    Set Suite Variable    ${DATADOG_APP_KEY}    ${DATADOG_APP_KEY}
    Set Suite Variable    ${DATADOG_SITE}    ${DATADOG_SITE}
    Set Suite Variable    ${METRIC_QUERY}    ${METRIC_QUERY}
    Set Suite Variable    ${JSON_PATH}    ${JSON_PATH}
    Set Suite Variable    ${HISTORY_RANGE}    ${HISTORY_RANGE}
    Set Suite Variable    ${NO_RESULT_OVERWRITE}    ${NO_RESULT_OVERWRITE}
    Set Suite Variable    ${NO_RESULT_VALUE}    ${NO_RESULT_VALUE}

*** Tasks ***
Query Datadog Metrics
    ${rsp}=    RW.Datadog.Metric Query
    ...    api_key=${DATADOG_API_KEY}
    ...    app_key=${DATADOG_APP_KEY}
    ...    query_str=${METRIC_QUERY}
    ...    site=${DATADOG_SITE}
    ...    within_time=${HISTORY_RANGE}
    ${metric}=    RW.Datadog.Handle Timeseries Data
    ...    json_path=${JSON_PATH}
    ...    rsp=${rsp}
    ...    no_result_overwrite=${NO_RESULT_OVERWRITE}
    ...    no_result_value=${NO_RESULT_VALUE}
    RW.Core.Push Metric    ${metric}

