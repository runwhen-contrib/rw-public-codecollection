*** Settings ***
Metadata          Author    Jonathan Funk
Metadata          Display Name    Sysdig Monitor Metric
Metadata          Supports    sysdig,sysdig-monitor 
Documentation     Queries the Sysdig data API to fetch metric data.
Force Tags        Prometheus    Prom    PromQL    Query    Metric    Aggregate
Suite Setup       Suite Initialization
Library           RW.Core
Library           RW.Sysdig

*** Keywords ***
Suite Initialization
    ${SYSDIG_TOKEN}=    RW.Core.Import Secret    SYSDIG_TOKEN
    ...    type=string
    ...    description=The sysdig API bearer token used in requests to authenticate.
    ...    pattern=\w*
    ...    example=my-token
    RW.Core.Import User Variable    SYSDIG_URL
    ...    type=string
    ...    description=The sysdig URL to perform requests against.
    ...    pattern=\w*
    ...    example=https://app.sysdigcloud.com
    RW.Core.Import User Variable    API_QUERY
    ...    type=string
    ...    description=The sysdig data api query to use. See https://docs.sysdig.com/en/docs/developer-tools/working-with-the-data-api/
    ...    pattern=\w*
    ...    example=[{"id": "cpu.used.percent", "aggregations": {"time": "timeAvg", "group": "avg"}}]
    Set Suite Variable    ${SYSDIG_TOKEN}    ${SYSDIG_TOKEN}

*** Tasks ***
Query Sysdig Metric Data And Pushing Metric
    ${rsp}=    RW.Sysdig.Get Metric Data    token=${SYSDIG_TOKEN}    sdc_url=${SYSDIG_URL}    query_str=${API_QUERY}
    ${metric}=    Set Variable    ${rsp}
    RW.Core.Push Metric    ${metric}
