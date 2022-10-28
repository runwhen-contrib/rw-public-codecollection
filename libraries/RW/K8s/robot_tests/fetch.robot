*** Settings ***
Library           RW.K8s
Library           RW.platform
Library           RW.Core
Library           OperatingSystem
Suite Setup       Suite Initialization

*** Tasks ***
Get Deployments With Client
    ${rsp}=    RW.K8s.Get
    ...    kind=Deployment
    ...    namespace=${K8S_TESTING_NS}
    ...    context=${K8S_TESTING_CONTEXT}
    ...    kubeconfig=${KUBECONFIG}
    Log    ${rsp}

Get Deployments With Client With Name
    ${rsp}=    RW.K8s.Get
    ...    kind=Deployment
    ...    name=${K8S_TESTING_NAME}
    ...    namespace=${K8S_TESTING_NS}
    ...    context=${K8S_TESTING_CONTEXT}
    ...    kubeconfig=${KUBECONFIG}
    Log    ${rsp}

Get Deployments With Client With Matching Label
    ${rsp}=    RW.K8s.Get
    ...    kind=Deployment
    ...    namespace=${K8S_TESTING_NS}
    ...    context=${K8S_TESTING_CONTEXT}
    ...    kubeconfig=${KUBECONFIG}
    ...    label_selector=service=search
    Log    ${rsp}

Get Events With Client
    ${rsp}=    RW.K8s.Get
    ...    kind=Event
    ...    namespace=${K8S_TESTING_NS}
    ...    context=${K8S_TESTING_CONTEXT}
    ...    kubeconfig=${KUBECONFIG}
    Log    ${rsp}

*** Keywords ***
Suite Initialization
    Set Suite Variable    ${KUBECONFIG_PATH}    %{KUBECONFIG_PATH}
    Set Suite Variable    ${K8S_TESTING_NS}    %{K8S_TESTING_NS}
    Set Suite Variable    ${K8S_TESTING_CONTEXT}    %{K8S_TESTING_CONTEXT}
    Set Suite Variable    ${K8S_TESTING_NAME}    %{K8S_TESTING_NAME}
    ${KUBECONFIG}=    Get File    ${KUBECONFIG_PATH}
    ${KUBECONFIG}=    Evaluate    RW.platform.Secret("kubeconfig", """${KUBECONFIG}""")
    Set Suite Variable    ${KUBECONFIG}    ${KUBECONFIG}
