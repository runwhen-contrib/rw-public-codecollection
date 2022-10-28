*** Settings ***
Metadata          Author    Jonathan Funk
Documentation     An SLI which periodically health checks the pods deployed by cert-manager
Force Tags        K8s    Kubernetes    Kube    K8    Kubectl    cert-manager
Suite Setup       Suite Initialization
Library           BuiltIn
Library           RW.Core
Library           RW.K8s
Library           RW.CertManager
Library           RW.platform
Library           OperatingSystem

*** Keywords ***
Suite Initialization
    ${kubeconfig}=    RW.Core.Import Secret    kubeconfig
    ${kubectl}=    RW.Core.Import Service    kubectl
    ${NAMESPACE}=    RW.Core.Import User Variable    NAMESPACE
    ...    type=string
    ...    description=The Kubernetes namespace your cert-manager resides in.
    ...    pattern=\w*
    ...    example=cert-manager
    ...    default=cert-manager

*** Tasks ***
Health Check cert-manager Pods
    ${rsp}=    RW.CertManager.Health Check
    ...    kubeconfig=${KUBECONFIG}
    ...    namespace=${NAMESPACE}
    ${metric}=    Evaluate    0 if ${rsp} is True else 1
    RW.Core.Push Metric    ${metric}
