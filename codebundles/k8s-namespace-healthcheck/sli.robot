*** Settings ***
Documentation       Scores the health of a Kubernetes namespace by examining both namespace events and Prometheus metrics.
Metadata            Author    Jonathan Funk

Library             BuiltIn
Library             RW.Prometheus
Library             RW.Core
Library             RW.Utils
Library             RW.K8s
Library             RW.platform
Library             OperatingSystem

Suite Setup         Suite Initialization

Force Tags          k8s    kubernetes    kube    namespace    prometheus    health


*** Keywords ***
Suite Initialization
    ${kubeconfig}=    RW.Core.Import Secret
    ...    kubeconfig
    ...    type=string
    ...    description=The kubernetes kubeconfig yaml containing connection configuration used to connect to cluster(s).
    ...    pattern=\w*
    ...    example=For examples, start here https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/
    ${kubectl}=    RW.Core.Import Service    kubectl
    ...    description=The location service used to interpret shell commands.
    ...    default=kubectl-service.shared
    ...    example=kubectl-service.shared
    ${NAMESPACE}=    RW.Core.Import User Variable    NAMESPACE
    ...    type=string
    ...    description=The name of the Kubernetes namespace to scope actions and searching to.
    ...    pattern=\w*
    ...    example=my-namespace
    ${CONTEXT}=    RW.Core.Import User Variable    CONTEXT
    ...    type=string
    ...    description=Which Kubernetes context to operate within.
    ...    pattern=\w*
    ...    example=my-main-cluster
    ${DISTRIBUTION}=    RW.Core.Import User Variable    DISTRIBUTION
    ...    type=string
    ...    description=Which distribution of Kubernetes to use for operations, such as: Kubernetes, OpenShift, etc.
    ...    pattern=\w*
    ...    enum=[Kubernetes,GKE,OpenShift]
    ...    example=Kubernetes
    ...    default=Kubernetes
    ${curl}=    RW.Core.Import Service    curl
    ...    type=string
    ...    description=The selected RunWhen Service to use for accessing services within a network.
    ...    pattern=\w*
    ...    example=curl-service.shared
    ...    default=curl-service.shared
    ${HEADERS}=    RW.Core.Import Secret    HEADERS
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
    ${binary_name}=    RW.K8s.Get Binary Name    ${DISTRIBUTION}
    Set Suite Variable    ${binary_name}    ${binary_name}


*** Tasks ***
Healthcheck A Kubernetes Namespace
    ${rsp}=    RW.Prometheus.Query Instant
    ...    api_url=${PROMETHEUS_HOSTNAME}
    ...    query=sum(kube_pod_container_status_restarts_total{namespace="${NAMESPACE}"})
    ...    optional_headers=${HEADERS}
    ...    step=30
    ...    target_service=${curl}
    ${data}=    Set Variable    ${rsp["data"]}
    ${namespace_pod_restarts}=    RW.Prometheus.Transform Data
    ...    data=${data}
    ...    method=Raw
    ${event_count}=    RW.K8s.Get Event Count
    ...    namespace=${NAMESPACE}
    ...    context=${CONTEXT}
    ...    kubeconfig=${kubeconfig}
    ...    target_service=${kubectl}
    ...    binary_name=${binary_name}
    ${metric}=    Evaluate    1 if ${event_count} == 0 and ${namespace_pod_restarts} == 0 else 0
    RW.Core.Push Metric    ${metric}

