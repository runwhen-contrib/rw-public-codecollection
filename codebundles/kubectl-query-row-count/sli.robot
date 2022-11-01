*** Settings ***
Metadata          Author    Jonathan Funk
Documentation     Run a kubectl query and retreive number of results as a metric.
Force Tags        K8s    Kubernetes    Kube    K8    Kubectl
Library           RW.Core
Library           RW.Kubectl

*** Tasks ***
Running Kubectl Command And Pushing Result Count
    Log    Importing secrets...
    ${secret}=    Import Secret    kubeconfig
    ${kubeconfig}=    Set Variable    ${secret.value}
    Log    Importing config variables...
    RW.Core.Import User Variable    KUBECTL_CMD
    Log    Running kubectl command...
    RW.Kubectl.Set Kubeconfig    ${kubeconfig}
    ${rsp}=    RW.Kubectl.Kubectl    ${KUBECTL_CMD}
    ${result_rows}=    Set Variable    ${rsp['stdout']}
    ${result_rows}=    RW.Kubectl.Stdout To Lists    ${result_rows}
    ${row_count}=    Evaluate    len($result_rows)
    Log    Query results: ${result_rows}
    Log    Query count: ${row_count}
    Log    Kubectl response: ${rsp}
    RW.Core.Push Metric    ${row_count}
