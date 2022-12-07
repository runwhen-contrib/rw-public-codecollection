*** Settings ***
Library           RW.K8s
Library           RW.Utils
Library           RW.platform
Library           RW.Core
Library           OperatingSystem
Suite Setup       Suite Initialization

*** Tasks ***
Get Deployments
    ${rsp}=    RW.K8s.Shell
    ...    cmd=kubectl get Deployment --context=${K8S_TESTING_CONTEXT} --namespace=${K8S_TESTING_NS} -o yaml
    ...    target_service=${kubectl}
    ...    kubeconfig=${KUBECONFIG}
    ${rsp}=    RW.Utils.Yaml To Dict    ${rsp}
    ${deployments}=    Set Variable    ${rsp["items"]}
    Log    ${deployments}

Get Deployment With Name
    ${rsp}=    RW.K8s.Shell
    ...    cmd=kubectl get Deployment/${K8S_TESTING_NAME} --context=${K8S_TESTING_CONTEXT} --namespace=${K8S_TESTING_NS} -o yaml
    ...    target_service=${kubectl}
    ...    kubeconfig=${KUBECONFIG}
    ${deployment}=    RW.Utils.Yaml To Dict    ${rsp}
    Log    ${deployment}

Get Deployments With Matching Label
    ${rsp}=    RW.K8s.Shell
    ...    cmd=kubectl get Deployment --selector=service=search --context=${K8S_TESTING_CONTEXT} --namespace=${K8S_TESTING_NS} -o yaml
    ...    target_service=${kubectl}
    ...    kubeconfig=${KUBECONFIG}
    ${rsp}=    RW.Utils.Yaml To Dict    ${rsp}
    ${deployments}=    Set Variable    ${rsp["items"]}
    ${history}=    RW.K8s.Get Shell History
    Log    ${deployments}
    Log    ${history}

Get Events
    ${rsp}=    RW.K8s.Shell
    ...    cmd=kubectl get Events --context=${K8S_TESTING_CONTEXT} --namespace=${K8S_TESTING_NS} -o yaml
    ...    target_service=${kubectl}
    ...    kubeconfig=${KUBECONFIG}
    ${rsp}=    RW.Utils.Yaml To Dict    ${rsp}
    ${events}=    Set Variable    ${rsp["items"]}
    Log    ${events}

Get Exec Stdout From Deploy Pod
    ${stdout}=    RW.K8s.Shell
    ...    cmd=kubectl exec -n jon-test deploy/crashbandicoot -it -- ls
    ...    target_service=${kubectl}
    ...    kubeconfig=${KUBECONFIG}
    Log    ${stdout}

*** Keywords ***
Suite Initialization
    RW.Core.Import Service    kubectl
    Set Suite Variable    ${kubectl}    ${kubectl}
    Set Suite Variable    ${KUBECONFIG_PATH}    %{KUBECONFIG_PATH}
    Set Suite Variable    ${K8S_TESTING_NS}    %{K8S_TESTING_NS}
    Set Suite Variable    ${K8S_TESTING_CONTEXT}    %{K8S_TESTING_CONTEXT}
    Set Suite Variable    ${K8S_TESTING_NAME}    %{K8S_TESTING_NAME}
    ${KUBECONFIG}=    Get File    ${KUBECONFIG_PATH}
    ${KUBECONFIG}=    Evaluate    RW.platform.Secret("kubeconfig", """${KUBECONFIG}""")
    Set Suite Variable    ${KUBECONFIG}    ${KUBECONFIG}
