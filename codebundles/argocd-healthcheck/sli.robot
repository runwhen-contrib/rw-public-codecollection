*** Settings ***
Metadata          Author    Paul Dittaro
Documentation     Check the health of ArgoCD platfrom by checking the availability of its underlying Deployments and StatefulSets.
Force Tags        K8s    Kubernetes    Kube    K8    Kubectl    argocd
Suite Setup       Suite Initialization
Library           BuiltIn
Library           RW.Core
Library           RW.ArgoCD

*** Keywords ***
Suite Initialization
    ${kubeconfig}=    RW.Core.Import Secret    kubeconfig
    ${kubectl}=    RW.Core.Import Service    kubectl
    ${NAMESPACE}=    RW.Core.Import User Variable    NAMESPACE
    ...    type=string
    ...    description=The Kubernetes namespace your ArgoCD install resides in.
    ...    pattern=\w*
    ...    example=argocd
    ...    default=argocd
    ${CONTEXT}=    RW.Core.Import User Variable    CONTEXT
    ...    type=string
    ...    description=Which Kubernetes context to operate within.
    ...    pattern=\w*
    ...    example=my-main-cluster
    ...    default=default
    Set Suite Variable    ${kubectl}    ${kubectl}
    Set Suite Variable    ${kubeconfig}    ${kubeconfig}
    Set Suite Variable    ${NAMESPACE}    ${NAMESPACE}
    Set Suite Variable    ${CONTEXT}    ${CONTEXT}

*** Tasks ***
ArgoCD Health Check
    ${health}=    RW.ArgoCD.Health Check
    ...    context=${CONTEXT}
    ...    namespace=${NAMESPACE}
    ...    target_service=${kubectl}
    ...    kubeconfig=${kubeconfig}
    ${metric}=    Evaluate    1 if ${health} is True else 0
    RW.Core.Push Metric    ${metric}
