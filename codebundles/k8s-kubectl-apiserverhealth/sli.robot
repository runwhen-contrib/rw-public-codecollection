*** Settings ***
Metadata          Author    Jonathan Funk
Documentation     Check the health of a Kubernetes API server using kubectl.
...               Returns 1 when OK, or a 0 in the case of an unhealthy API server.
Force Tags        K8s    Kubernetes    Kube    K8    Kubectl
Suite Setup       Suite Initialization
Library           BuiltIn
Library           RW.Core
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
    Set Suite Variable    ${KUBECTL_COMMAND}    ${binary_name} get --raw='/livez' --context ${CONTEXT} -n ${NAMESPACE}

*** Tasks ***
Running Kubectl Check Against API Server
    ${stdout}=    RW.K8s.Shell
    ...    cmd=${KUBECTL_COMMAND}
    ...    target_service=${kubectl}
    ...    kubeconfig=${KUBECONFIG}
    ${metric}=    Evaluate    1 if "${stdout}" == "ok" else 0
    RW.Core.Push Metric    ${metric}
