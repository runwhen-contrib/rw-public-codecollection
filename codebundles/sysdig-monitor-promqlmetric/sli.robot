*** Settings ***
Metadata          Author    Jonathan Funk
Documentation     Queries the Sysdig data API with a PromQL query to fetch metric data.
Force Tags        sysdig    Prom    PromQL    Query    Metric    Aggregate
Suite Setup       Suite Initialization
Library           RW.Core
Library           RW.Sysdig

*** Keywords ***
Suite Initialization
    ${HEADERS}=    RW.Core.Import Secret    HEADERS
    ...    type=string
    ...    description=A json string of headers to include in the request against the Prometheus instance. This can include your token.
    ...    pattern=\w*
    ...    default="{}"
    ...    example='{"my-header":"my-value", "Authorization": "Bearer mytoken"}'
    RW.Core.Import User Variable    PROMQL_URL
    ...    type=string
    ...    description=The promql endpoint to perform requests against.
    ...    pattern=\w*
    ...    example=https://app.sysdigcloud.com/api/v2/promql
    RW.Core.Import User Variable    QUERY
    ...    type=string
    ...    description=The PromQL statement used to query metrics.
    ...    pattern=\w*
    ...    example=sysdig_container_cpu_quota_used_percent > 75 or sysdig_container_memory_limit_used_percent> 75
    RW.Core.Import User Variable    TRANSFORM
    ...    type=string
    ...    enum=[Max,Average,Minimum,Sum,First,Last]
    ...    description=What transform method to apply to the column data. First and Last are position relative, so Last is the most recent value.
    ...    default=Last
    ...    example=Last
    RW.Core.Import User Variable    STEP
    ...    type=string
    ...    description=The step interval in seconds requested from the Prometheus API.
    ...    pattern="^[0-9]*$"
    ...    default=30
    ...    example=30
    RW.Core.Import User Variable    SECONDS_IN_PAST
    ...    type=string
    ...    description=Determines the range of historical data queried starting from now back a number of seconds.
    ...    pattern="^[0-9]*$"
    ...    default=600
    ...    example=600
    RW.Core.Import User Variable    DATA_COLUMN
    ...    type=string
    ...    description=Which column of the result data to perform aggregation on. Typically 0 is the timestamp, whereas 1 is the metric value.
    ...    pattern="^[0-9]*$"
    ...    default=1
    ...    example=1
    Set Suite Variable    ${OPTIONAL_HEADERS}    %{OPTIONAL_HEADERS}

*** Tasks ***
Querying PromQL Endpoint And Pushing Metric Data
    ${rsp}=    RW.Sysdig.Promql Query
    ...    api_url=${PROMQL_URL}
    ...    query=${QUERY}
    ...    step=${STEP}
    ...    seconds_in_past=${SECONDS_IN_PAST}
    ...    optional_headers=${HEADERS}
    ${data}=    Set Variable    ${rsp["data"]}
    ${metric}=    RW.Sysdig.Transform Data    ${data}    ${TRANSFORM}
    RW.Core.Push Metric    ${metric}
