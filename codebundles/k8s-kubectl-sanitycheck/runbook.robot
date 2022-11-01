*** Settings ***
Documentation     Used for troubleshooting the shellservice-based kubectl service
Suite Setup       My Suite Setup
Library           BuiltIn
Library           RW.Core
Library           RW.K8s

*** Keywords ***
My Suite Setup
    ${kubeconfig}=    RW.Core.Import Secret    kubeconfig
    ${kubectl}=    RW.Core.Import Service    kubectl

*** Tasks ***
Check Kubeconfig Secret Exists
    [Documentation]    Makes sure that our kubeconfig length is non-zero
    ${kubeconfig_len}=    Evaluate    len($kubeconfig.value)
    Should Not Be Equal As Integers    ${kubeconfig_len}    0

Test Generic Shell Service Connectivity
    ${rsp}=    RW.Core.Shell    ls
    ...    service=${kubectl}
    Log    Response from shell shellservice was ${rsp} with stdout ${rsp.stdout}
    RW.Core.Add To Report    shell service stdout: ${rsp.stdout} and stderr: ${rsp.stderr}

Check Kubectl contexts
    ${rsp}=    RW.K8s.Kubectl    config get-contexts
    ...    target_service=${kubectl}
    ...    kubeconfig=${kubeconfig}
    Log    Response from kubectl shellservice was ${rsp} with stdout ${rsp.stdout}
    RW.Core.Add To Report    config get-contexts stdout: ${rsp.stdout} and stderr: ${rsp.stderr}
    ${rsp}=    RW.K8s.Kubectl    config current-context
    ...    target_service=${kubectl}
    ...    kubeconfig=${kubeconfig}
    Log    Response from kubectl shellservice was ${rsp} with stdout ${rsp.stdout}
    RW.Core.Add To Report    config current-context stdout: ${rsp.stdout} and stderr: ${rsp.stderr}

Test Command Chains
    ${rsp}=    RW.K8s.Kubectl    config current-context; ls; echo $PATH
    ...    target_service=${kubectl}
    ...    kubeconfig=${kubeconfig}
    Log    Response from kubectl shellservice was ${rsp} with stdout ${rsp.stdout}
    RW.Core.Add To Report    stdout: ${rsp.stdout} and stderr: ${rsp.stderr}

Test Kubectl Get Pods
    ${rsp}=    RW.K8s.Kubectl    get pods
    ...    target_service=${kubectl}
    ...    kubeconfig=${kubeconfig}
    Log    Response from kubectl get pods was ${rsp} with stdout ${rsp.stdout}
    RW.Core.Add To Report    kubectl get pods stdout: ${rsp.stdout} and stderr: ${rsp.stderr}
    ${rsp}=    RW.K8s.Kubectl    get all
    ...    target_service=${kubectl}
    ...    kubeconfig=${kubeconfig}
    Log    Response from kubectl get all was ${rsp} with stdout ${rsp.stdout}
    RW.Core.Add To Report    kubectl get all stdout: ${rsp.stdout} and stderr: ${rsp.stderr}
