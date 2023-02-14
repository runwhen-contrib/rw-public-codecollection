*** Settings ***
Metadata          Author    Shea Stewart
Documentation     This SLI uses kubectl to investigate a namespace for issues and produce an overall score of namespace health. Looks for container restarts, events, and pods not ready. Produces a value between 0 (completely failing thet test) and 1 (fully passying the test). 
Force Tags        K8s    Kubernetes    Kube    K8
Suite Setup       Suite Initialization
Library           BuiltIn
Library           RW.Core
Library           RW.Utils
Library           RW.K8s
Library           RW.platform
Library           OperatingSystem

*** Keywords ***
Suite Initialization
    ${kubeconfig}=    RW.Core.Import Secret    kubeconfig
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
    ...    description=The name of the Kubernetes namespace to scope actions and searching to. Supports csv list of namespaces, or ALL. 
    ...    pattern=\w*
    ...    example=ALL
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
    ${EVENT_TYPE}=    RW.Core.Import User Variable    EVENT_TYPE
    ...    type=string
    ...    description=The error pattern to use when grep-ing logs or searching events.
    ...    pattern=\w*
    ...    example=Normal|Warning
    ...    default=Warning
    ${EVENT_AGE}=    RW.Core.Import User Variable    EVENT_AGE
    ...    type=string
    ...    description=The time window in minutes as to when the event was last seen.
    ...    pattern=\w*
    ...    example=5m
    ...    default=5m
    ${EVENT_THRESHOLD}=    RW.Core.Import User Variable    EVENT_THRESHOLD
    ...    type=string
    ...    description=The maximum total events to be still considered healthy. 
    ...    pattern=\w*
    ...    example=2
    ...    default=0
    ${CONTAINER_RESTART_AGE}=    RW.Core.Import User Variable    CONTAINER_RESTART_AGE
    ...    type=string
    ...    description=The time window in minutes as search for container restarts.
    ...    pattern=\w*
    ...    example=5m
    ...    default=5m
    ${CONTAINER_RESTART_THRESHOLD}=    RW.Core.Import User Variable    CONTAINER_RESTART_THRESHOLD
    ...    type=string
    ...    description=The maximum total container restarts to be still considered healthy. 
    ...    pattern=\w*
    ...    example=2
    ...    default=0
    ${binary_name}=    RW.K8s.Get Binary Name    ${DISTRIBUTION}
    Set Suite Variable    ${binary_name}    ${binary_name}

*** Tasks ***

Get Event Count and Score
    ${event_count}=    RW.K8s.Count Events By Age and Type
    ...    namespace=${NAMESPACE}
    ...    context=${CONTEXT}
    ...    kubeconfig=${kubeconfig}
    ...    target_service=${kubectl}
    ...    binary_name=${binary_name}
    ...    event_age=${EVENT_AGE}
    ...    event_type=${EVENT_TYPE}
    Log    ${event_count} total events found with event type ${event_type} up to age ${event_age}
    ${event_score}=    Evaluate    1 if ${event_count} <= ${EVENT_THRESHOLD} else 0
    Set Global Variable    ${event_score}

Get Container Restarts and Score
    ${container_restart_count}=    RW.K8s.Count Container Restarts By Age
    ...    namespace=${NAMESPACE}
    ...    context=${CONTEXT}
    ...    kubeconfig=${kubeconfig}
    ...    target_service=${kubectl}
    ...    binary_name=${binary_name}
    ...    container_restart_age=${CONTAINER_RESTART_AGE}
    Log    ${container_restart_count} total container restarts found in the last ${CONTAINER_RESTART_AGE}
    ${container_restart_score}=    Evaluate    1 if ${container_restart_count} <= ${CONTAINER_RESTART_THRESHOLD} else 0
    Set Global Variable    ${container_restart_score}

Get NotReady Pods
    ${pods_notready_count}=    RW.K8s.Count Notready Pods
    ...    namespace=${NAMESPACE}
    ...    context=${CONTEXT}
    ...    kubeconfig=${kubeconfig}
    ...    target_service=${kubectl}
    ...    binary_name=${binary_name}
    Log    ${pods_notready_count} total unready pods
    ${pods_notready_score}=    Evaluate    1 if ${pods_notready_count} == 0 else 0
    Set Global Variable    ${pods_notready_score}

Generate Namspace Score
    ${namspace_health_score}=      Evaluate     (${event_score} + ${container_restart_score} + ${pods_notready_score}) / 3
    RW.Core.Push Metric    ${namspace_health_score}