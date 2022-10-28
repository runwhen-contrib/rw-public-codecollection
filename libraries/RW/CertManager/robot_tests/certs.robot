*** Settings ***
Library           RW.CertManager
Library           RW.platform
Library           RW.Core
Library           OperatingSystem
Suite Setup       Suite Initialization

*** Keywords ***
Suite Initialization
    Set Suite Variable    ${KUBECONFIG_PATH}    %{KUBECONFIG_PATH}
    Set Suite Variable    ${K8S_TESTING_NS}    %{K8S_TESTING_NS}
    Set Suite Variable    ${K8S_TESTING_CONTEXT}    %{K8S_TESTING_CONTEXT}
    Set Suite Variable    ${K8S_TESTING_NAME}    %{K8S_TESTING_NAME}
    Set Suite Variable    ${K8S_TESTING_LABELS}    %{K8S_TESTING_LABELS}
    ${KUBECONFIG}=    Get File    ${KUBECONFIG_PATH}
    ${KUBECONFIG}=    Evaluate    RW.platform.Secret("kubeconfig", """${KUBECONFIG}""")
    Set Suite Variable    ${KUBECONFIG}    ${KUBECONFIG}

*** Tasks ***
Check Certification Expiry
    ${rsp}=    RW.CertManager.Check Certificate Dates
    ...    days_left_allowed=60
    ...    kubeconfig=${KUBECONFIG}
    ...    namespace=cert-manager
    Log    ${rsp}

Health Check
    ${rsp}=    RW.CertManager.Health Check
    ...    kubeconfig=${KUBECONFIG}
    ...    namespace=cert-manager
    Log    ${rsp}
