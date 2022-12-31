*** Settings ***
Metadata          Author    Jonathan Funk
Documentation     Run a PromQL query against Prometheus instant query API, perform a provided transform, and return the result.
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
    ...    enum=[Raw,Max,Average,Minimum,Sum,First,Last]
    ...    description=What transform method to apply to the column data. First and Last are position relative, so Last is the most recent value. Use Raw to skip transform. 
    ...    default=Last
    ...    example=Last
    RW.Core.Import User Variable    STEP
    ...    type=string
    ...    description=The step interval in seconds requested from the Prometheus API.
    ...    pattern="^[0-9]*$"
    ...    default=30
    ...    example=30
    RW.Core.Import User Variable    DATA_COLUMN
    ...    type=string
    ...    description=Which column of the result data to perform aggregation on. Typically 0 is the timestamp, whereas 1 is the metric value.
    ...    pattern="^[0-9]*$"
    ...    default=1
    ...    example=1
    RW.Core.Import User Variable    NO_RESULT_OVERWRITE
    ...    type=string
    ...    description=Determine how to handle queries with no result data. Set to Yes to write a metric (specified below) or No to accept the null result.
    ...    pattern=\w*
    ...    enum=[Yes,No]
    ...    default=No
    RW.Core.Import User Variable    NO_RESULT_VALUE
    ...    type=string
    ...    description=Set the metric value that should be stored when no data result is available.
    ...    pattern=\d*
    ...    default=0
    ...    example=0
    Set Suite Variable    ${CURL_SERVICE}    ${CURL_SERVICE}
    Set Suite Variable    ${OPTIONAL_HEADERS}    ${OPTIONAL_HEADERS}
    Set Suite Variable    ${NO_RESULT_OVERWRITE}    ${NO_RESULT_OVERWRITE}
    Set Suite Variable    ${NO_RESULT_VALUE}    ${NO_RESULT_VALUE}

*** Tasks ***
Querying Prometheus Instance And Pushing Aggregated Data
    ${rsp}=    RW.Prometheus.Query Instant
    ...    api_url=${PROMETHEUS_HOSTNAME}
    ...    query=${QUERY}
    ...    optional_headers=${OPTIONAL_HEADERS}
    ...    step=${STEP}
    ...    target_service=${CURL_SERVICE}
    ${data}=    Set Variable    ${rsp["data"]}
    ${metric}=    RW.Prometheus.Transform Data
    ...    data=${data}
    ...    method=${TRANSFORM}
    ...    no_result_overwrite=${NO_RESULT_OVERWRITE}
    ...    no_result_value=${NO_RESULT_VALUE}
    RW.Core.Push Metric    ${metric}
