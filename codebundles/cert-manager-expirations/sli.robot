*** Settings ***
Metadata          Author    Jonathan Funk
Metadata          Display Name    Cert-manager Expirations
Metadata          Supports    K8s,cert-manager
Documentation     Retrieve number of expired TLS certificates managed by cert-manager within a given window.
...               The metric pushed is the number of certs within the configured expiration window.
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
    ${EXPIRATION_WINDOW}=    RW.Core.Import User Variable    EXPIRATION_WINDOW
    ...    type=string
    ...    description=The number of days at which a certificate is considered 'about to expire' for the metric pushed.
    ...    pattern="^[0-9]*$"
    ...    default=30
    ...    example=30
    ${CONTEXT}=    RW.Core.Import User Variable    CONTEXT
    ...    type=string
    ...    description=Which Kubernetes context to operate within.
    ...    pattern=\w*
    ...    example=my-main-cluster

*** Tasks ***
Inspect Certification Expiration Dates
    ${rsp}=    RW.K8s.Shell
    ...    cmd=kubectl get Certificate --context=${CONTEXT} --namespace=${NAMESPACE} -o yaml
    ...    target_service=${kubectl}
    ...    kubeconfig=${KUBECONFIG}
    ${certs}=    RW.Utils.Yaml To Dict    ${rsp}
    ${rsp}=    RW.CertManager.Get Expiring Certs
    ...    certs=${certs}
    ...    days_left_allowed=${EXPIRATION_WINDOW}
    ${metric}=    Evaluate    len($rsp)
    RW.Core.Push Metric    ${metric}
