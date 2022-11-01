*** Settings ***
Documentation     Run a kubectl query and return the average of all results for a given field.
Library           RW.Core
Library           RW.Kubectl

*** Tasks ***
Running Kubectl Command And Pushing The Average Of A Column Value
    Log    Importing secrets...
    ${secret}=    Import Secret    kubeconfig
    ${kubeconfig}=    Set Variable    ${secret.value}
    Log    Importing config variables...
    RW.Core.Import User Variable    KUBECTL_CMD
    RW.Core.Import User Variable    STDOUT_COLUMN_INDEX
    RW.Core.Import User Variable    COLUMN_TRANSFORM
    Log    Running kubectl command...
    RW.Kubectl.Set Kubeconfig    ${kubeconfig}
    ${rsp}=    RW.Kubectl.Kubectl    ${KUBECTL_CMD}
    Log    Parsing stdout and applying transform
    ${column_data}=    ${rsp['stdout']}
    ${transformed_data}=    Evaluate    ${COLUMN_TRANSFORM}
    ${average}=    Evaluate    sum(${transformed_data})/len(${transformed_data})
    Log    Column data: ${column_data}
    Log    Transformed data: ${transformed_data}
    Log    Average to push: ${average}
    RW.Core.Push Metric    ${average}
