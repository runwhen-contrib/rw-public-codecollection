*** Settings ***
Metadata          Author    Jonathan Funk
Documentation     Uses kubectl (or equivalent) to query the state of a patroni cluster and determine if it's healthy.
Force Tags        K8s    Kubernetes    Kube    K8    Patroni    Health
Suite Setup       Suite Initialization
Library           BuiltIn
Library           RW.Core
Library           RW.Utils
Library           RW.K8s
Library           RW.Patroni
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
    ${PATRONI_RESOURCE_NAME}=    RW.Core.Import User Variable    PATRONI_RESOURCE_NAME
    ...    type=string
    ...    description=Determine which object is queried for health information.
    ...    pattern=\w*
    ...    example=statefulset/my-patroni
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
    ${binary_name}=    RW.K8s.Get Binary Name    ${DISTRIBUTION}
    Set Suite Variable    ${binary_name}    ${binary_name}
    Set Suite Variable    ${kubeconfig}    ${kubeconfig}
    Set Suite Variable    ${kubectl}    ${kubectl}
    Set Suite Variable    ${NAMESPACE}    ${NAMESPACE}
    Set Suite Variable    ${CONTEXT}    ${CONTEXT}
    Set Suite Variable    ${PATRONI_RESOURCE_NAME}    ${PATRONI_RESOURCE_NAME}

*** Tasks ***
Measure Patroni Member Lag
    ${stdout}=    RW.K8s.Shell
    ...    cmd=${binary_name} exec ${PATRONI_RESOURCE_NAME} -n ${NAMESPACE} --context ${CONTEXT} -it -- patronictl list -e -f yaml
    ...    target_service=${kubectl}
    ...    kubeconfig=${kubeconfig}
    ${state_yaml}=    RW.Utils.Yaml To Dict    yaml_str=${stdout}
    ${max_lag}=    RW.Patroni.K8s Patroni Get Max Lag    state=${state_yaml}
    ${metric}=    Set Variable     ${max_lag}
    RW.Core.Push Metric    ${metric}
