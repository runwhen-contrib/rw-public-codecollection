*** Settings ***
Documentation     Run a kubectl query and return the first result for a given field.
Library           RW.Core
Library           RW.Kubectl

*** Tasks ***
Running Kubectl Command And Pushing Target Value
    Log    Importing secrets...
    ${secret}=    Import Secret    kubeconfig
    ${kubeconfig}=    Set Variable    ${secret.value}
    Log    Importing config variables...
    RW.Core.Import User Variable    KUBECTL_CMD
    RW.Core.Import User Variable    STDOUT_COLUMN_INDEX
    Log    Running kubectl command...
    RW.Kubectl.Set Kubeconfig    ${kubeconfig}
    ${rsp}=    RW.Kubectl.Kubectl    ${KUBECTL_CMD}
    ${result_rows}=    Set Variable    ${rsp['stdout']}
    ${result_rows}=    RW.Kubectl.Stdout To Lists    ${result_rows}
    ${data_column}=    RW.Kubectl.Get Kubectl List Column    ${result_rows}    ${STDOUT_COLUMN_INDEX}
    ${float_values}=    RW.Kubectl.Remove Units    ${data_column}
    ${first_val}=    Set Variable    ${float_values[0]}
    Log    Query results: ${result_rows}
    Log    Data Column: ${data_column}
    Log    Floats: ${float_values}
    Log    Kubectl response: ${rsp}
    RW.Core.Push Metric    ${first_val}
