*** Settings ***
Metadata          Author    Paul Dittaro
Documentation     Check the health status of applications managed by ArgoCD
Force Tags        K8s    Kubernetes    Kube    K8    Kubectl    argocd
Suite Setup       Suite Initialization
Library           BuiltIn
Library           RW.Core
Library           RW.K8s
Library           RW.Utils
Library           RW.ArgoCD
Library           RW.platform
Library           OperatingSystem

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

*** Tasks ***
Inspect Applications
    Log    Importing config variables...

    RW.Core.Import User Variable    APPLICATIONS
    ...    type=string
    ...    description=List of applications to check health. If empty will check health of all managed applications.
    ...    default=None
    ${PARSED_APPLICATIONS}=    Evaluate    set($APPLICATIONS.split(',')) if $APPLICATIONS is not "" else None

    RW.Core.Import User Variable    HEALTH_STATUS
    ...    type=string
    ...    description=The ArgoCD Application health status
    ...    example=Healthy
    ...    default=Healthy
    ${PARSED_HEALTH}=    Evaluate    set($APPLICATIONS.split(',')) if $APPLICATIONS is not "" else None

    ${rsp}=    RW.K8s.Shell
    ...    cmd=kubectl get applications.argoproj.io --context=${CONTEXT} --namespace=${NAMESPACE} -o yaml
    ...    target_service=${kubectl}
    ...    kubeconfig=${KUBECONFIG}
    ${dict}=    RW.Utils.Yaml To Dict    ${rsp}
    ${rsp}=    RW.ArgoCD.Filter Applications
    ...    dict=${dict}
    ...    applications=${APPLICATIONS}
    ...    health_status=${healthstatus}
    ${metric}=    Evaluate    len($rsp)
    Log    metric: ${metric}
    RW.Core.Push Metric    ${metric}
