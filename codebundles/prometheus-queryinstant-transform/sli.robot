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
    ...    description=A json string of optional headers to include in the request against the Prometheus instance.
    ...    pattern=\w*
    ...    default="{}"
    ...    example='{"my-header":"my-value"}'
    RW.Core.Import User Variable    PROMETHEUS_HOSTNAME
    ...    type=string
    ...    description=The hostname of the Prometheus instance.
    ...    pattern=\w*
    ...    example=my_metric_name_with_underscores
    RW.Core.Import User Variable    QUERY
    ...    type=string
    ...    description=The PromQL statement used. To fetch workspace data use the format: workspace_name__slx_name
    ...    pattern=\w*
    ...    example=my_workspace_name__my_slx_name_underscored
    RW.Core.Import User Variable    TRANSFORM
    ...    type=string
    ...    enum=[Raw,Max,Average,Minimum,Sum,First,Last]
    ...    description=What transform method to apply to the column data. First and Last are position relative, so Last is the most recent value. Use Raw if you're already aggregating in your query.
    ...    default=Raw
    ...    example=Raw
    RW.Core.Import User Variable    STEP
    ...    type=string
    ...    description=The step interval in seconds requested from the Prometheus API.
    ...    pattern="^[0-9a-z]*$"
    ...    default=30s
    ...    example=30s
    RW.Core.Import User Variable    SECONDS_IN_PAST
    ...    type=string
    ...    description=Determines the range of historical data queried starting from now back a number of seconds.
    ...    pattern="^[0-9]*$"
    ...    default=600
    ...    example=600
    RW.Core.Import User Variable    DATA_COLUMN
    ...    type=string
    ...    description=Which column of the result data to perform transformation on. Typically 0 is the timestamp, whereas 1 is the metric value.
    ...    pattern="^[0-9]*$"
    ...    default=1
    ...    example=1
    Set Suite Variable    ${CURL_SERVICE}    ${CURL_SERVICE}
    Set Suite Variable    ${OPTIONAL_HEADERS}    ${OPTIONAL_HEADERS}

*** Tasks ***
Querying Prometheus Instance And Pushing Aggregated Data
    ${rsp}=    RW.Prometheus.Query Instant
    ...    api_url=${PROMETHEUS_HOSTNAME}
    ...    query=${QUERY}
    ...    optional_headers=${OPTIONAL_HEADERS}
    ...    step=${STEP}
    ...    seconds_in_past=36000
    ...    target_service=${CURL_SERVICE}
    ${data}=    Set Variable    ${rsp["data"]}
    ${metric}=    RW.Prometheus.Transform Data    ${data}    ${TRANSFORM}
    RW.Core.Push Metric    ${metric}
