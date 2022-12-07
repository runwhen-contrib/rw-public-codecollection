*** Settings ***
Metadata          Author    Jonathan Funk
Documentation     Run a PromQL query against Prometheus range query API, perform a provided transform, and return the result.
Force Tags        Prometheus    Prom    PromQL    Query    Metric    Aggregate
Suite Setup       Suite Initialization
Library           RW.Core
Library           RW.Prometheus

*** Keywords ***
Suite Initialization
    ${CURL_SERVICE}=    RW.Core.Import Service    curl
    ...    type=string
    ...    description=The selected RunWhen Service to use for accessing services within a network.
    ...    pattern=\w*
    ...    example=curl-service.shared
    ...    default=curl-service.shared
    ${OPTIONAL_HEADERS}=    RW.Core.Import Secret    OPTIONAL_HEADERS
    ...    type=string
    ...    description=A json string of headers to include in the request against the Prometheus instance. This can include your token.
    ...    pattern=\w*
    ...    default="{}"
    ...    example='{"my-header":"my-value", "Authorization": "Bearer mytoken"}'
    RW.Core.Import User Variable    PROMETHEUS_HOSTNAME
    ...    type=string
    ...    description=The prometheus endpoint to perform requests against.
    ...    pattern=\w*
    ...    example=https://myprometheus/api/v1/
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
    Set Suite Variable    ${CURL_SERVICE}    ${CURL_SERVICE}
    Set Suite Variable    ${OPTIONAL_HEADERS}    ${OPTIONAL_HEADERS}

*** Tasks ***
Querying Prometheus Instance And Pushing Aggregated Data
    ${rsp}=    RW.Prometheus.Query Range
    ...    api_url=${PROMETHEUS_HOSTNAME}
    ...    query=${QUERY}
    ...    optional_headers=${OPTIONAL_HEADERS}
    ...    step=${STEP}
    ...    seconds_in_past=${SECONDS_IN_PAST}
    ...    target_service=${CURL_SERVICE}
    ${data}=    Set Variable    ${rsp["data"]}
    ${metric}=    RW.Prometheus.Transform Data    ${data}    ${TRANSFORM}
    RW.Core.Push Metric    ${metric}
