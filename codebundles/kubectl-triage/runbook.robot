*** Settings ***
Documentation     Triage and troubleshoot a kubernetes namespace
Library           RW.Core
Library           RW.Report
Library           RW.Kubectl

*** Tasks ***
Post Logs Report
    Log    Importing secrets...
    ${secret}=    Import Secret    kubeconfig
    ${kubeconfig}=    Set Variable    ${secret.value}
    Log    Importing config variables...
    RW.Core.Import User Variable    CONTEXT
    RW.Core.Import User Variable    NAMESPACE
    RW.Core.Import User Variable    RESOURCE_NAME
    RW.Core.Import User Variable    SINCE
    RW.Core.Import User Variable    EVENTS_LEVEL
    Log    Running kubectl commands...
    RW.Kubectl.Set Kubeconfig    ${kubeconfig}
    ${logs_cmd}=    Set Variable    --context ${CONTEXT} -n ${NAMESPACE} logs ${RESOURCE_NAME} --since=${SINCE}
    ${logs}=    RW.Kubectl.Kubectl    ${logs_cmd}
    ${logs}=    Set Variable    ${logs["stdout"]}
    ${events_cmd}=    Set Variable    --context ${CONTEXT} -n ${NAMESPACE} get events --field-selector reason=${EVENTS_LEVEL}
    ${events}=    RW.Kubectl.Kubectl    ${events_cmd}
    ${events}=    Set Variable    ${events["stdout"]}
    log    ${logs_cmd}
    log    ${logs}
    log    ${events_cmd}
    log    ${events}
    Add To Report    Flux System Triage Report
    Add To Report    Kubernetes Deployment Logs from command: kubectl ${logs_cmd}
    Add Pre To Report    ${logs}
    Add To Report    Kubernetes Error Events from command: kubectl ${events_cmd}
    Add Pre To Report    ${events}
    ${full_report}=    Export Report As String
    Log    The Flux Triage Report is: ${full_report}
    Log    Finishing Task
