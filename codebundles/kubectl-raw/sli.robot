*** Settings ***
Library           RW.Core
Library           RW.Kubectl

*** Tasks ***
Running Kubectl Command And Pushing Result Count
    Log    Importing secrets...
    ${secret}=    Import Secret    kubeconfig
    ${kubeconfig}=   Set Variable    ${secret.value}
    
    Log    Importing config variables...
    RW.Core.Import User Variable    KUBECTL_CMD
    RW.Core.Import User Variable    STDOUT_MATCH

    Log    Running kubectl command...
    RW.Kubectl.Set Kubeconfig    ${kubeconfig}
    ${rsp}=    RW.Kubectl.Kubectl    ${KUBECTL_CMD}

    ${stdout}=     Set Variable    ${rsp['stdout']}
    ${match}=       Evaluate    0 if '${STDOUT_MATCH}' in '${stdout}' else 1   
    
    
    Log     stdout: ${stdout}
    Log     match for: ${STDOUT_MATCH}
    Log     match: ${match}
    RW.Core.Push Metric    ${match}
