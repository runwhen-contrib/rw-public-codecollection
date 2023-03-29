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

Get Connection Utilization Rate
    [Documentation]    Get the connection utilization (current/available) for all instances and score against threshold (1 = below threshold, 0 = above)
    ${connection_utilization_rsp}=      RW.Prometheus.Query Instant
    ...    api_url=https://monitoring.googleapis.com/v1/projects/${PROJECT_ID}/location/global/prometheus/api/v1
    ...    query=sum(mongodb_ss_connections{conn_type="current",rs_state="1",${PROMQL_FILTER}}) by (instance)/sum(mongodb_ss_connections{conn_type=~"current|available",rs_state="1",${PROMQL_FILTER}}) by (instance) *100
    ...    optional_headers=${access_token_header_secret}
    ...    target_service=${CURL_SERVICE}
    ${max_connection_utilization_value}=        RW.Utils.Json To Metric
    ...    data=${connection_utilization_rsp}
    ...    search_filter=data.result[]
    ...    calculation_field=value[1].to_number(@)
    ...    calculation=Max
    Log    The max connection utilization (current / available) is ${max_connection_utilization_value}
    ${connection_score}=    Evaluate    1 if ${max_connection_utilization_value} < ${CONNECTION_UTILIZATION_THRESHOLD} else 0
    Set Global Variable    ${max_connection_utilization_value}
    Set Global Variable    ${connection_score}

Get MongoDB Member State Health
    [Documentation]    Fetch the replication state of each member and ensure they are within acceptable parameters. https://www.mongodb.com/docs/manual/reference/replica-states/
    ${acceptable_member_states}=  Set Variable  PRIMARY|SECONDARY|ARBITER
    ${member_state_rsp}=      RW.Prometheus.Query Instant
    ...    api_url=https://monitoring.googleapis.com/v1/projects/${PROJECT_ID}/location/global/prometheus/api/v1
    ...    query=mongodb_members_id{member_state!~"${acceptable_member_states}",${PROMQL_FILTER}}
    ...    optional_headers=${access_token_header_secret}
    ...    target_service=${CURL_SERVICE}
    ${member_state_value}=        RW.Utils.Json To Metric
    ...    data=${member_state_rsp}
    ...    search_filter=data.result[]
    ...    calculation_field=value[1].to_number(@)
    ...    calculation=Count
    Log    The count of members that are NOT ${acceptable_member_states} is: ${member_state_value}
    ${member_state_score}=    Evaluate    1 if ${member_state_value} == 0 else 0
    Set Global Variable    ${member_state_value}
    Set Global Variable    ${member_state_score}

Get MongoDB Replication Lag
    [Documentation]    Fetch the replication lag (in seconds) of all instances and determine if they are within acceptable parameters. https://www.mongodb.com/docs/manual/reference/replica-states/
    ${replication_lag_rsp}=      RW.Prometheus.Query Instant
    ...    api_url=https://monitoring.googleapis.com/v1/projects/${PROJECT_ID}/location/global/prometheus/api/v1
    ...    query=(max by (instance) (mongodb_rs_members_optimeDate{member_state="PRIMARY",${PROMQL_FILTER}}) - min by (instance) (mongodb_rs_members_optimeDate{member_state="SECONDARY",${PROMQL_FILTER}})) / 1000
    ...    optional_headers=${access_token_header_secret}
    ...    target_service=${CURL_SERVICE}
    ${replication_lag_value}=        RW.Utils.Json To Metric
    ...    data=${replication_lag_rsp}
    ...    search_filter=data.result[]
    ...    calculation_field=value[1].to_number(@)
    ...    calculation=Max
    Log    Max lag of any instance is ${replication_lag_value} seconds. 
    ${replication_lag_score}=    Evaluate    1 if ${replication_lag_value} < 0 else 0
    Set Global Variable    ${replication_lag_value}
    Set Global Variable    ${replication_lag_score}

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
    ${mongodb_score}=      Evaluate  (${up_score}+${connection_score}+${member_state_value}) / 3
    ${health_score}=      Convert to Number    ${mongodb_score}  2
    RW.Core.Push Metric    ${health_score}    
    RW.Core.Push Metric    ${up_value}    sub_name=up
    RW.Core.Push Metric    ${connection_score}    sub_name=connection
    RW.Core.Push Metric    ${member_state_score}    sub_name=member_state

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
    ...    default=instance=~".+"
    ...    example=namespace="mongodb-test"
    RW.Core.Import User Variable    CONNECTION_UTILIZATION_THRESHOLD
    ...    type=string
    ...    description=The percentage of used vs available connections which is deemed acceptable. Utilization above this number will negatively affect the service health score. 
    ...    pattern=\d*
    ...    default=80
    ...    example=80
    RW.Core.Import User Variable    MAX_LAG
    ...    type=string
    ...    description=The maximum lag (in seconds) between members that is deemed acceptable. Lag above this number will negatively affect the service health score. 
    ...    pattern=\d*
    ...    default=10
    ...    example=10
    Set Suite Variable    ${CURL_SERVICE}    ${CURL_SERVICE}
    Set Suite Variable    ${PROJECT_ID}    ${PROJECT_ID}
