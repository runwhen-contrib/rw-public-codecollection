*** Settings ***
Documentation       Returns the number of events with matching messages as an SLI metric.
Metadata            Author    Jonathan Funk
Metadata          Display Name    Kubernetes Event Query 
Metadata          Supports    Kubernetes,AKS,EKS,GKE,OpenShift
Library             BuiltIn
Library             RW.Core
Library             RW.Utils
Library             RW.K8s
Library             RW.platform
Library             OperatingSystem

Suite Setup         Suite Initialization

Force Tags          k8s    kubernetes    kube    k8    events    


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
    ${EVENT_PATTERN}=    RW.Core.Import User Variable    EVENT_PATTERN
    ...    type=string
    ...    description=What pattern to look for in event messages to return as results.
    ...    pattern=\w*
    ...    example=Unable to attach or mount volumes
    ...    default=*
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
    ${binary_name}=    RW.K8s.Get Binary Name    ${DISTRIBUTION}
    Set Suite Variable    ${binary_name}    ${binary_name}

*** Tasks ***
Get Number Of Matching Events
    ${event_count}=    RW.K8s.Get Event Count
    ...    event_pattern=${EVENT_PATTERN}
    ...    namespace=${NAMESPACE}
    ...    context=${CONTEXT}
    ...    kubeconfig=${kubeconfig}
    ...    target_service=${kubectl}
    ...    binary_name=${binary_name}
    ${metric}=    Set Variable    ${event_count}
    RW.Core.Push Metric    ${metric}
