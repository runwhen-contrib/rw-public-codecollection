*** Settings ***
Metadata          Author    Jonathan Funk
Documentation     An SLI which polls the Kubernetes API server with kubectl and returns 0 when OK
...               or a 1 in the case of an unhealthy API server.
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
    ${kubectl}=    RW.Core.Import Service    kubectl
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
    Set Suite Variable    ${KUBECTL_COMMAND}    kubectl get --raw='/livez' --context ${CONTEXT} -n ${NAMESPACE}
    ${DISTRIBUTION}=    RW.Core.Import User Variable    DISTRIBUTION
    ...    type=string
    ...    description=Which distribution of Kubernetes to use for operations, such as: Kubernetes, OpenShift, etc.
    ...    pattern=\w*
    ...    enum=[Kubernetes,GKE,OpenShift]
    ...    example=Kubernetes

*** Tasks ***
Running Kubectl Check Against API Server
    ${rsp}=    RW.K8s.Kubectl    ${KUBECTL_COMMAND}
    ...    target_service=${kubectl}
    ...    kubeconfig=${kubeconfig}
    ${stdout}=    Set Variable    ${rsp.stdout}
    ${metric}=    Evaluate    0 if "${stdout}" == "ok" else 1
    RW.Core.Push Metric    ${metric}
