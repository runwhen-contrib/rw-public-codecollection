*** Settings ***
Metadata          Author    Jonathan Funk
Documentation     Run a kubectl command and retreive the stdout as a report.
...               Typically used in conjunction with other codebundles.
Force Tags        K8s    Kubernetes    Kube    K8    Kubectl    Stdout    Command    Run
Suite Setup       Suite Initialization
Library           RW.Core
Library           RW.K8s
Library           RW.platform

*** Keywords ***
Suite Initialization
    ${kubeconfig}=    RW.Core.Import Secret    kubeconfig
    ${kubectl}=    RW.Core.Import Service    kubectl
    ${KUBECTL_COMMAND}=    RW.Core.Import User Variable    KUBECTL_COMMAND
    ...    type=string
    ...    description=The kubectl command to run and retreive stdout from.
    ...    pattern=\w*
    ...    example=kubectl get pods --context my-context -n my-namespace
    ...    example=kubectl get pods
    ${DISTRIBUTION}=    RW.Core.Import User Variable    DISTRIBUTION
    ...    type=string
    ...    description=Which distribution of Kubernetes to use for operations, such as: Kubernetes, OpenShift, etc.
    ...    pattern=\w*
    ...    enum=[Kubernetes,GKE,OpenShift]
    ...    example=Kubernetes
    Set Suite Variable    ${kubeconfig}    ${kubeconfig}

*** Tasks ***
Running Kubectl And Adding Stdout To Report
    RW.Core.Add Pre To Report    Running Command: ${KUBECTL_COMMAND}
    ${rsp}=    RW.K8s.Kubectl    ${KUBECTL_COMMAND}
    ...    target_service=${kubectl}
    ...    kubeconfig=${kubeconfig}
    ${stdout}=    Set Variable    ${rsp.stdout}
    RW.Core.Add Pre To Report    ${stdout}
