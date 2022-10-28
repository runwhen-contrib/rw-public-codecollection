*** Settings ***
Metadata          Author    Jonathan Funk
Documentation     An SLI that performs a query against a Prometheus' HTTP query API, retrieves the response,
...               performs an aggregation operation on that result before pushing it as a metric.
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
    ${ORGANIZATION_ID}=    RW.Core.Import Secret    ORGANIZATION_ID
    ...    type=string
    ...    description=Determines which set of metrics are queried if prometheus is behind Cortex.
    ...    pattern=\w*
    ...    example=myorgid
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
    RW.Core.Import User Variable    AGGREGATION
    ...    type=string
    ...    enum=[Max,Average,Minimum,Sum,First,Last]
    ...    description=What aggregation method to apply to the column data. First and Last are position relative, so Last is the most recent value.
    ...    default=Average
    ...    example=Average
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
    Set Suite Variable    ${ORGANIZATION_ID}    ${ORGANIZATION_ID}

*** Tasks ***
Querying Prometheus Instance And Pushing Aggregated Data
    ${rsp}=    RW.Prometheus.Range Query
    ...    api_url=${PROMETHEUS_HOSTNAME}
    ...    query=${QUERY}
    ...    org_id=${ORGANIZATION_ID}
    ...    step=${STEP}
    ...    seconds_in_past=36000
    ...    target_service=${CURL_SERVICE}
    ${data}=    Set Variable    ${rsp["data"]}
    ${metric}=    RW.Prometheus.Aggregate Data    ${data}    ${AGGREGATION}
    RW.Core.Push Metric    ${metric}
