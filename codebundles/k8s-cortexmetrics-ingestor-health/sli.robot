*** Settings ***
Documentation       Uses kubectl to query the state of a ingestor ring and determine if it's healthy. Returns 1 if healthy, 0 if unhealthy.
Metadata            Author    Shea Stewart
Metadata          Display Name    Cortex Metrics Ingester Health 
Metadata          Supports    Kubernetes,cortex
Library             BuiltIn
Library             RW.Core
Library             RW.Utils
Library             RW.K8s
Library             RW.platform
Library             OperatingSystem

Suite Setup         Suite Initialization

Force Tags          k8s    kubernetes    kube    k8    cortex    metrics    health


*** Tasks ***
Determine Cortex Ingester Ring Health
    ${stdout}=    RW.K8s.Shell
    ...    cmd=${binary_name} exec ${CORTEX_RESOURCE_NAME} -n ${NAMESPACE} --context ${CONTEXT} -it -- wget -O - --header 'Accept: application/json' ${CORTEX_INGESTER_RING_URL}
    ...    target_service=${kubectl}
    ...    kubeconfig=${kubeconfig}

    ${filter_active_ingesters}=    RW.Utils.Search Json
    ...    data=${stdout}
    ...    pattern=shards[?state == 'ACTIVE'].[id, state, timestamp]

    ${total_active_ingesters}=    Get Length    ${filter_active_ingesters}
    ${metric}=    Evaluate    1 if ${total_active_ingesters}==${EXPECTED_RING_MEMBERS} else 0
    RW.Core.Push Metric    ${metric}


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
    ${CORTEX_RESOURCE_NAME}=    RW.Core.Import User Variable    CORTEX_RESOURCE_NAME
    ...    type=string
    ...    description=Determine which Kubernetes object is queried for cortex ingester health information.
    ...    pattern=\w*
    ...    default=deployment/cortex-distributor
    ...    example=deployment/cortex-distributor
    ${CORTEX_INGESTER_RING_URL}=    RW.Core.Import User Variable
    ...    CORTEX_INGESTER_RING_URL
    ...    type=string
    ...    description=Host to query that resolves the ingester ring endpoint. Typically http://127.0.0.1:8080/ring if querying from a distributor pod.
    ...    pattern=\w*
    ...    default='http://127.0.0.1:8080/ring'
    ...    example='http://127.0.0.1:8080/ring'
    ${NAMESPACE}=    RW.Core.Import User Variable    NAMESPACE
    ...    type=string
    ...    description=The name of the Kubernetes namespace where cortex is deployed.
    ...    pattern=\w*
    ...    default=cortex
    ...    example=cortex
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
    ${EXPECTED_RING_MEMBERS}=    RW.Core.Import User Variable    EXPECTED_RING_MEMBERS
    ...    type=string
    ...    description=Total number of ring members that should be ACTIVE.
    ...    pattern=^\d+$
    ...    example=3
    ...    default=3
    ${binary_name}=    RW.K8s.Get Binary Name    ${DISTRIBUTION}
    Set Suite Variable    ${binary_name}    ${binary_name}
    Set Suite Variable    ${kubeconfig}    ${kubeconfig}
    Set Suite Variable    ${EXPECTED_RING_MEMBERS}    ${EXPECTED_RING_MEMBERS}
    Set Suite Variable    ${DISTRIBUTION}    ${DISTRIBUTION}
    Set Suite Variable    ${NAMESPACE}    ${NAMESPACE}
    Set Suite Variable    ${CORTEX_RESOURCE_NAME}    ${CORTEX_RESOURCE_NAME}
    Set Suite Variable    ${CORTEX_INGESTER_RING_URL}    ${CORTEX_INGESTER_RING_URL}
