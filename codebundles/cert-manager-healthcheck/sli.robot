*** Settings ***
Metadata          Author    Jonathan Funk
Metadata          Display Name    Cert-Manager Health Check
Metadata          Supports    K8s,cert-manager
Documentation     Check the health of pods deployed by cert-manager.
Force Tags        K8s    Kubernetes    Kube    K8    Kubectl    cert-manager
Suite Setup       Suite Initialization
Library           BuiltIn
Library           RW.Core
Library           RW.K8s
Library           RW.Utils
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
    ${CONTEXT}=    RW.Core.Import User Variable    CONTEXT
    ...    type=string
    ...    description=Which Kubernetes context to operate within.
    ...    pattern=\w*
    ...    example=my-main-cluster

*** Tasks ***
Health Check cert-manager Pods
    ${rsp}=    RW.K8s.Shell
    ...    cmd=kubectl get pods --field-selector=status.phase=Running --selector=app.kubernetes.io/instance=cert-manager --context=${CONTEXT} --namespace=${NAMESPACE} -o yaml
    ...    target_service=${kubectl}
    ...    kubeconfig=${KUBECONFIG}
    ${pods}=    RW.Utils.Yaml To Dict    ${rsp}
    ${rsp}=    RW.CertManager.Health Check
    ...    cm_pods=${pods}
    ${metric}=    Evaluate    1 if ${rsp} is True else 0
    RW.Core.Push Metric    ${metric}
