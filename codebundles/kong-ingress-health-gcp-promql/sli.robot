*** Settings ***
Metadata          Author    Shea Stewart            
Documentation     Uses promql on the Ops Suite API to determine the health of a Kong managed ingress resource
...               and pushes the result as an SLI metric. Produces a 1 for a healthy resource, or 0 for an unhealthy resource. 
Force Tags        GCP    OpsSuite    PromQL    Prometheus  Kubernetes
Library           RW.GCP.OpsSuite
Library           RW.Core
Library           RW.Utils
Library           RW.Prometheus
Library    String
Suite Setup       Suite Initialization

*** Tasks ***
Get Access Token
    ${access_token_header_secret}=  RW.GCP.OpsSuite.Get Access Token Header  gcp_credentials=${ops-suite-sa}
    Set Global Variable    ${access_token_header_secret}

Get HTTP Error Rate
    ${rsp}=      RW.Prometheus.Query Instant
    ...    api_url=https://monitoring.googleapis.com/v1/projects/${PROJECT_ID}/location/global/prometheus/api/v1
    ...    query=rate(kong_http_requests_total{service="${INGRESS_SERVICE}",code=~"${HTTP_ERROR_CODES}"}[${HTTP_ERROR_RATE_WINDOW}])
    ...    optional_headers=${access_token_header_secret}
    ...    target_service=${CURL_SERVICE}
    ${http_error_rate}=    RW.Prometheus.Transform Data
    ...    data=${rsp["data"]}
    ...    method=Raw
    ...    no_result_overwrite=Yes
    ...    no_result_value=0
    Log    ${http_error_rate} total http errors found matching error code ${HTTP_ERROR_CODES} up to age ${HTTP_ERROR_RATE_WINDOW}
    ${http_error_rate_score}=    Evaluate    1 if ${http_error_rate} <= ${HTTP_ERROR_RATE_THRESHOLD} else 0
    Set Global Variable    ${http_error_rate}
    Set Global Variable    ${http_error_rate_score}

Get Upstream Health
    ${healthcheck_metric}=      RW.Prometheus.Query Instant
    ...    api_url=https://monitoring.googleapis.com/v1/projects/${PROJECT_ID}/location/global/prometheus/api/v1
    ...    query=kong_upstream_target_health{upstream="${INGRESS_UPSTREAM}",state="healthchecks_off"}
    ...    optional_headers=${access_token_header_secret}
    ...    target_service=${CURL_SERVICE}
    ${healthcheck_metric_value}=    RW.Prometheus.Transform Data
    ...    data=${healthcheck_metric["data"]}
    ...    method=Raw
    ...    no_result_overwrite=Yes
    ...    no_result_value=0
    IF    "${healthcheck_metric_value}" == "1"
        Log    "Healthcheck is disabled for this target" 
    END


    ${error_metrics}=      RW.Prometheus.Query Instant
    ...    api_url=https://monitoring.googleapis.com/v1/projects/${PROJECT_ID}/location/global/prometheus/api/v1
    ...    query=kong_upstream_target_health{upstream="${INGRESS_UPSTREAM}",state=~"dns_error|unhealthy"}
    ...    optional_headers=${access_token_header_secret}
    ...    target_service=${CURL_SERVICE}
    ${error_metric_value}=    RW.Prometheus.Transform Data
    ...    data=${error_metrics["data"]}
    ...    method=Sum
    ...    no_result_overwrite=Yes
    ...    no_result_value=0
    Log    The query for dns_error or unhealthy produced a sum of ${error_metric_value}. Anything greater than 0 means that the resource is in an error state. 
    ${error_metrics_score}=    Evaluate    1 if ${error_metric_value} == 0 else 0
    Set Global Variable    ${error_metric_value}
    Set Global Variable    ${error_metrics_score}
    
Get Request Latency Rate
    ${request_latency_99th}=      RW.Prometheus.Query Instant
    ...    api_url=https://monitoring.googleapis.com/v1/projects/${PROJECT_ID}/location/global/prometheus/api/v1
    ...    query=histogram_quantile(0.99, sum(rate(kong_request_latency_ms_bucket{service="${INGRESS_SERVICE}"}[1m])) by (le))
    ...    optional_headers=${access_token_header_secret}
    ...    target_service=${CURL_SERVICE}
    ${request_latency_99th_value}=    RW.Prometheus.Transform Data
    ...    data=${request_latency_99th["data"]}
    ...    method=Raw
    ...    no_result_overwrite=Yes
    ...    no_result_value=0
    Log    The 99th percentile for Kong and the upstream to process requests is ${request_latency_99th_value}ms. 
    ${request_latency_score}=    Evaluate    1 if ${request_latency_99th_value} >= ${REQUEST_LATENCY_THRESHOLD} else 0
    Set Global Variable    ${request_latency_99th_value}
    Set Global Variable    ${request_latency_score}


Generate Kong Ingress Score
    ${ingress_health_score}=      Evaluate  (${http_error_rate_score} + ${error_metrics_score} + ${request_latency_score}) / 3
    ${health_score}=      Convert to Number    ${ingress_health_score}  2
    RW.Core.Push Metric    ${health_score}    
    RW.Core.Push Metric    ${http_error_rate}    sub_name=http_error_rate
    RW.Core.Push Metric    ${error_metric_value}    sub_name=error_metric_value
    RW.Core.Push Metric    ${request_latency_99th_value}    sub_name=request_latency_99th_value

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
    RW.Core.Import User Variable    HTTP_ERROR_CODES
    ...    type=string
    ...    description=Specify the HTTP status codes that will be included when calculating the error rate in promql compatible pattern.
    ...    pattern=\w*
    ...    example=5.* (matches any 500 error code)
    ...    default=5.*
    RW.Core.Import User Variable    HTTP_ERROR_RATE_WINDOW
    ...    type=string
    ...    description=Specify the window of time used to measure the rate. 
    ...    pattern=\w*
    ...    example=1m
    ...    default=1m
    RW.Core.Import User Variable    HTTP_ERROR_RATE_THRESHOLD
    ...    type=string
    ...    description=Specify the error rate threshold that is considered unhealthy. Measured in errors/s.
    ...    pattern=\w*
    ...    example=2
    ...    default=2
    RW.Core.Import User Variable    INGRESS_UPSTREAM
    ...    type=string
    ...    description=The name of the upstream target associated with the ingress object. This is the prometheus label named `upstream`. Typically in the format of the local dns address in the namespace, such as [service-name].[namespace-name].[service-port].svc
    ...    pattern=\w*
    ...    example=frontend-external.online-boutique.80.svc
    RW.Core.Import User Variable    INGRESS_SERVICE
    ...    type=string
    ...    description=The name of the service that related to the ingress object. This is the prometheus label named `service`. Typically in the form of [namespace].[object-name].[service-name].[service-port]
    ...    pattern=\w*
    ...    example=online-boutique.ob.frontend-external.80
    RW.Core.Import User Variable    REQUEST_LATENCY_THRESHOLD
    ...    type=string
    ...    description=The threshold in ms for request latency to be considered unhealthy. 
    ...    pattern=\w*
    ...    example=50
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
    Set Suite Variable    ${PROJECT_ID}    ${PROJECT_ID}
    Set Suite Variable    ${NO_RESULT_OVERWRITE}     ${NO_RESULT_OVERWRITE}
    Set Suite Variable    ${NO_RESULT_VALUE}     ${NO_RESULT_VALUE}
