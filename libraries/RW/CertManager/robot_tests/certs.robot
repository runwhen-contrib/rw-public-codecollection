*** Settings ***
Library           RW.CertManager
Library           RW.K8s
Library           RW.platform
Library           RW.Core
Library           RW.Utils
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
    ${kubectl}=    RW.Core.Import Service    kubectl
    Set Suite Variable    ${kubeconfig}    ${kubeconfig}

*** Tasks ***
Check Certification Expiry
    ${rsp}=    RW.K8s.Shell
    ...    cmd=kubectl get Certificate --context=${K8S_TESTING_CONTEXT} --namespace=cert-manager -o yaml
    ...    target_service=${kubectl}
    ...    kubeconfig=${KUBECONFIG}
    ${certs}=    RW.Utils.Yaml To Dict    ${rsp}
    ${rsp}=    RW.CertManager.Get Expiring Certs
    ...    certs=${certs}
    ...    days_left_allowed=60
    Log    ${rsp}

Health Check
    ${rsp}=    RW.K8s.Shell
    ...    cmd=kubectl get pods --field-selector=status.phase=Running --selector=app.kubernetes.io/instance=cert-manager --context=${K8S_TESTING_CONTEXT} --namespace=cert-manager -o yaml
    ...    target_service=${kubectl}
    ...    kubeconfig=${KUBECONFIG}
    ${pods}=    RW.Utils.Yaml To Dict    ${rsp}
    ${rsp}=    RW.CertManager.Health Check
    ...    cm_pods=${pods}
    Log    ${rsp}
