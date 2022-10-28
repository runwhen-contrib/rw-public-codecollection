*** Settings ***
Library           RW.Artifactory
Library           RW.K8s
Library           RW.platform
Library           RW.Core
Library           OperatingSystem
Suite Setup       Suite Initialization

*** Keywords ***
Suite Initialization
    Set Suite Variable    ${ARTIFACTORY_URL}    %{ARTIFACTORY_URL}
    Set Suite Variable    ${ARTIFACTORY_HEALTH_URL}    %{ARTIFACTORY_HEALTH_URL}
    Set Suite Variable    ${ARTIFACTORY_REGISTRY_URL}    %{ARTIFACTORY_REGISTRY_URL}
    Set Suite Variable    ${ARTIFACTORY_KUBECONFIG_PATH}    %{ARTIFACTORY_KUBECONFIG_PATH}
    Set Suite Variable    ${ARTIFACTORY_NS}    %{ARTIFACTORY_NS}
    Set Suite Variable    ${ARTIFACTORY_CONTEXT}    %{ARTIFACTORY_CONTEXT}
    ${KUBECONFIG}=    Get File    ${ARTIFACTORY_KUBECONFIG_PATH}
    ${KUBECONFIG}=    Evaluate    RW.platform.Secret("kubeconfig", """${KUBECONFIG}""")
    Set Suite Variable    ${KUBECONFIG}    ${KUBECONFIG}

*** Tasks ***
Health Check Artifactory
    ${rsp}=    RW.Artifactory.Get Health    url=${ARTIFACTORY_HEALTH_URL}
    ${artifactory_health}=    Set Variable    ${rsp}
    ${status}=    RW.Artifactory.Validate Health    health_data=${artifactory_health}
    Log    ${status}

*** Tasks ***
Get Artifactory Pods
    ${rsp}=    RW.K8s.Get
    ...    kind=Pod
    ...    namespace=${ARTIFACTORY_NS}
    ...    context=${ARTIFACTORY_CONTEXT}
    ...    kubeconfig=${KUBECONFIG}
    ...    label_selector=app=artifactory
    ...    output_format=yaml
    ...    unpack_from_items=True
    Log    ${rsp}

Get Artifactory Stateful Sets And Check Ready
    ${rsp}=    RW.K8s.Get
    ...    kind=StatefulSet
    ...    namespace=${ARTIFACTORY_NS}
    ...    context=${ARTIFACTORY_CONTEXT}
    ...    kubeconfig=${KUBECONFIG}
    ...    unpack_from_items=True
    ${all_ready}=    RW.K8s.Stateful Sets Ready
    ...    statefulsets=${rsp}
    ...    unpack_from_items=False
    Log    ${all_ready}
    Log    ${rsp}

Health Check Artifactory Registry
    Log    hello

Pull Artifactory Image
    Log    hello
