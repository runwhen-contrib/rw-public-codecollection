*** Settings ***
Documentation     Run a kubectl query and return the sum of all results for a given field.
Library           RW.Core
Library           RW.Kubectl
# EXPERIMENTAL

*** Tasks ***
Running Kubectl Command And Pushing Sum Of Column Values
    Log    Importing secrets...
    ${secret}=    Import Secret    kubeconfig
    ${kubeconfig}=    Set Variable    ${secret.value}
    Log    Importing config variables...
    RW.Core.Import User Variable    KUBECTL_CMD
    Log    Running kubectl command...
    RW.Kubectl.Set Kubeconfig    ${kubeconfig}
    ${rsp}=    RW.Kubectl.Kubectl    ${KUBECTL_CMD}
    ${result_rows}=    Evaluate    ${rsp.splitlines()}
    ${row_count}=    Evaluate    len(${result_rows})
    Log    Query results: ${result_rows}
    Log    Query count: ${row_count}
    Log    Kubectl response: ${rsp}
    RW.Core.Push Metric    ${row_count}
