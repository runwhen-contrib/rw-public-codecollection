*** Settings ***
Metadata          Author    Shea Stewart            
Documentation     Performs a metric query using a PromQL statement on the Ops Suite API
...               and pushes the result as an SLI metric.
Force Tags        GCP    OpsSuite    PromQL    Prometheus  Kubernetes
Library           RW.GCP.OpsSuite
Library           RW.Core
Library           RW.Utils
Library           RW.Prometheus
Suite Setup       Suite Initialization

*** Tasks ***
Run Prometheus Instant Query Against Google Prom API Endpoint
    # Disable logging to hide auth token details
    Set Log Level    NONE
    
    # Get an oauth2 access token from service account json
    ${token}=    RW.GCP.OpsSuite.Get Token  gcp_credentials=${ops-suite-sa}
    ${header_secret}=   RW.Utils.Create Secret  key=optional_headers  val={"Authorization":"Bearer ${token}"}
    
    # Re-enable logging
    Set Log Level    INFO

    # Use Prom Instant Query with Google API and Oauth access token
    ${rsp}=      RW.Prometheus.Query Instant
    ...    api_url=https://monitoring.googleapis.com/v1/projects/${PROJECT_ID}/location/global/prometheus/api/v1
    ...    query=${PROMQL_STATEMENT}
    ...    optional_headers=${header_secret}
    ...    target_service=${CURL_SERVICE}
    ${data}=    Set Variable    ${rsp["data"]}
    ${metric}=    RW.Prometheus.Transform Data
    ...    data=${data}
    ...    method=${TRANSFORM}
    ...    no_result_overwrite=${NO_RESULT_OVERWRITE}
    ...    no_result_value=${NO_RESULT_VALUE}

    # Push metric to RunWhen    
    RW.Core.Push Metric    ${metric}

*** Keywords ***
Suite Initialization
    ${CURL_SERVICE}=    RW.Core.Import Service    curl
    ...    type=string
    ...    description=The selected RunWhen Service to use for accessing services within a network.
    ...    pattern=\w*
    ...    example=curl-service.shared
    ...    default=curl-service.shared
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
    RW.Core.Import User Variable    PROMQL_STATEMENT
    ...    type=string
    ...    description=The PromQL statement used to query metrics from the GCP OpsSuite PromQL API.
    ...    pattern=\w*
    ...    example=sum(up offset 1m)
    RW.Core.Import User Variable    TRANSFORM
    ...    type=string
    ...    enum=[Raw,Max,Average,Minimum,Sum,First,Last]
    ...    description=What transform method to apply to the column data. First and Last are position relative, so Last is the most recent value. Use Raw to skip transform. 
    ...    default=Last
    ...    example=Last
    RW.Core.Import User Variable    DATA_COLUMN
    ...    type=string
    ...    description=Which column of the result data to perform aggregation on. Typically 0 is the timestamp, whereas 1 is the metric value.
    ...    pattern="^[0-9]*$"
    ...    default=1
    ...    example=1
    RW.Core.Import User Variable    NO_RESULT_OVERWRITE
    ...    type=string
    ...    description=Determine how to handle queries with no result data. Set to Yes to write a metric (specified below) or No to accept the null result. 
    ...    enum=[Yes,No]
    ...    default=No
    RW.Core.Import User Variable    NO_RESULT_VALUE
    ...    type=string
    ...    description=Set the metric value that should be stored when no data result is available.
    ...    default=0
    ...    example=0
    Set Suite Variable    ${CURL_SERVICE}    ${CURL_SERVICE}
    Set Suite Variable    ${TRANSFORM}    ${TRANSFORM}
    Set Suite Variable    ${DATA_COLUMN}    ${DATA_COLUMN}
    Set Suite Variable    ${PROJECT_ID}    ${PROJECT_ID}
    Set Suite Variable    ${PROMQL_STATEMENT}    ${PROMQL_STATEMENT}
    Set Suite Variable    ${NO_RESULT_OVERWRITE}     ${NO_RESULT_OVERWRITE}
    Set Suite Variable    ${NO_RESULT_VALUE}     ${NO_RESULT_VALUE}
