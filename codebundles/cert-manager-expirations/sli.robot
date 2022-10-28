*** Settings ***
Metadata          Author    Jonathan Funk
Documentation     An SLI which queries cert-manager resources to check expiration times of TLS certificates.
...               The metric pushed is the number of certs within the configured expiration window.
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
    ${EXPIRATION_WINDOW}=    RW.Core.Import User Variable    EXPIRATION_WINDOW
    ...    type=string
    ...    description=The number of days at which a certificate is considered 'about to expire' for the metric pushed.
    ...    pattern="^[0-9]*$"
    ...    default=30
    ...    example=30

*** Tasks ***
Inspect Certification Expiration Dates
    ${rsp}=    RW.CertManager.Check Certificate Dates
    ...    days_left_allowed=${EXPIRATION_WINDOW}
    ...    kubeconfig=${KUBECONFIG}
    ...    namespace=${NAMESPACE}
    ${metric}=    Evaluate    len($rsp)
    RW.Core.Push Metric    ${metric}
