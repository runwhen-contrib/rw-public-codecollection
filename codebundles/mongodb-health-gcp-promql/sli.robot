*** Settings ***
Metadata          Author    Shea Stewart            
Documentation     Uses promql on the Ops Suite API to determine the health of a MongoDB database instance
...               and pushes the result as an SLI metric. Produces a 1 for a healthy resource, or 0 for an unhealthy resource. 
Force Tags        GCP    OpsSuite    PromQL    MongoDB 
Library           RW.GCP.OpsSuite
Library           RW.Core
Library           RW.Utils
Library           RW.Prometheus
Library           String
Suite Setup       Suite Initialization

*** Tasks ***
Get Access Token
    ${access_token_header_secret}=  RW.GCP.OpsSuite.Get Access Token Header  gcp_credentials=${ops-suite-sa}
    Set Global Variable    ${access_token_header_secret}

Get Instance Status
    [Documentation]    Get the count of mongodb_up returning 1 dividided by the number of expected instances
    ${up_rsp}=      RW.Prometheus.Query Instant
    ...    api_url=https://monitoring.googleapis.com/v1/projects/${PROJECT_ID}/location/global/prometheus/api/v1
    ...    query=sum(mongodb_up{${PROMQL_FILTER}})/(count(count by (instance) (mongodb_up{${PROMQL_FILTER}})))
    ...    optional_headers=${access_token_header_secret}
    ...    target_service=${CURL_SERVICE}
    ${up_value}=        RW.Utils.Json To Metric
    ...    data=${up_rsp}
    ...    search_filter=data.result[]
    ...    calculation_field=value[1].to_number(@)
    ...    calculation=Sum
    Log    mongodb_up returned a total of ${up_value}
    ${up_score}=    Evaluate    1 if ${up_value} >= 1 else 0
    Set Global Variable    ${up_value}
    Set Global Variable    ${up_score}

# Get Upstream Health
#     ${healthcheck_rsp}=      RW.Prometheus.Query Instant
#     ...    api_url=https://monitoring.googleapis.com/v1/projects/${PROJECT_ID}/location/global/prometheus/api/v1
#     ...    query=sum(kong_upstream_target_health{upstream="${INGRESS_UPSTREAM}",state="healthchecks_off"})
#     ...    optional_headers=${access_token_header_secret}
#     ...    target_service=${CURL_SERVICE}
#     ${healthcheck_metric_value}=        RW.Utils.Json To Metric
#     ...    data=${healthcheck_rsp}
#     ...    search_filter=data.result[]
#     ...    calculation_field=value[1].to_number(@)
#     ...    calculation=Sum
#     # ${healthcheck_metric_value}=    Set Variable   ${healthcheck_rsp["data"]["result"][0]["value"][1]}
#     IF    ${healthcheck_metric_value} >= 1
#         Log    "Healthcheck is disabled for this target" 
#     END


#     ${error_rsp}=      RW.Prometheus.Query Instant
#     ...    api_url=https://monitoring.googleapis.com/v1/projects/${PROJECT_ID}/location/global/prometheus/api/v1
#     ...    query=kong_upstream_target_health{upstream="${INGRESS_UPSTREAM}",state=~"dns_error|unhealthy"}
#     ...    optional_headers=${access_token_header_secret}
#     ...    target_service=${CURL_SERVICE}
#     ${error_metric_value}=        RW.Utils.Json To Metric
#     ...    data=${error_rsp}
#     ...    search_filter=data.result[]
#     ...    calculation_field=value[1].to_number(@)
#     ...    calculation=Sum
#     Log    The query for dns_error or unhealthy produced a sum of ${error_metric_value}. Anything greater than 0 means that the resource is in an error state. 
#     ${error_metrics_score}=    Evaluate    1 if ${error_metric_value} == 0 else 0
#     Set Global Variable    ${error_metric_value}
#     Set Global Variable    ${error_metrics_score}
    
# Get Request Latency Rate
#     ${request_latency_99th_rsp}=      RW.Prometheus.Query Instant
#     ...    api_url=https://monitoring.googleapis.com/v1/projects/${PROJECT_ID}/location/global/prometheus/api/v1
#     ...    query=histogram_quantile(0.99, sum(rate(kong_request_latency_ms_bucket{service="${INGRESS_SERVICE}"}[1m])) by (le))
#     ...    optional_headers=${access_token_header_secret}
#     ...    target_service=${CURL_SERVICE}
#     ${request_latency_99th_value}=    RW.Prometheus.Transform Data
#     ...    data=${request_latency_99th_rsp["data"]}
#     ...    method=Raw
#     ...    no_result_overwrite=Yes
#     ...    no_result_value=0
#     Log    The 99th percentile for Kong and the upstream to process requests is ${request_latency_99th_value}ms. 
#     ${request_latency_score}=    Evaluate    1 if ${request_latency_99th_value} <= ${REQUEST_LATENCY_THRESHOLD} else 0
#     Set Global Variable    ${request_latency_99th_value}
#     Set Global Variable    ${request_latency_score}


Generate MongoDB Score
    ${mongodb_score}=      Evaluate  (${up_score}) / 3
    ${health_score}=      Convert to Number    ${mongodb_score}  2
    RW.Core.Push Metric    ${health_score}    
    RW.Core.Push Metric    ${up_value}    sub_name=up
    # RW.Core.Push Metric    ${error_metric_value}    sub_name=error_metric_value
    # RW.Core.Push Metric    ${request_latency_99th_value}    sub_name=request_latency_99th_value

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
    # RW.Core.Import User Variable    NAMESPACE
    # ...    type=string
    # ...    description=The Kubernetes Namespace to query for MongoDB Instances
    # ...    pattern=\w*
    # ...    example=my-namespace
    RW.Core.Import User Variable    PROMQL_FILTER
    ...    type=string
    ...    description=The prometheus labels used to filter results. 
    ...    pattern=\w*
    ...    example=namespace="mongodb-test"
    Set Suite Variable    ${CURL_SERVICE}    ${CURL_SERVICE}
    Set Suite Variable    ${PROJECT_ID}    ${PROJECT_ID}
