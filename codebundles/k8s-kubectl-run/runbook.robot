*** Settings ***
Metadata          Author    Jonathan Funk
Documentation     This codebundle runs an arbitrary kubectl command and writes the stdout to a report.
...               Typically used in conjunction with other codebundles.
Force Tags        K8s    Kubernetes    Kube    K8    Kubectl    Stdout    Command    Run
Metadata          Canonical Name    Kubernetes Run Shell Command
Metadata          Supports    Kubernetes,AKS,EKS,GKE,OpenShift
Suite Setup       Suite Initialization
Library           RW.Core
Library           RW.K8s
Library           RW.Utils
Library           RW.platform

*** Keywords ***
Suite Initialization
    ${kubeconfig}=    RW.Core.Import Secret    kubeconfig
    ...    type=string
    ...    description=The kubernetes kubeconfig yaml containing connection configuration used to connect to cluster(s).
    ...    pattern=\w*
    ...    example=For examples, start here https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/
    ${kubectl}=    RW.Core.Import Service    kubectl
    ...    description=The location service used to interpret shell commands.
    ...    default=kubectl-service.shared
    ...    example=kubectl-service.shared
    ${KUBECTL_COMMAND}=    RW.Core.Import User Variable    KUBECTL_COMMAND
    ...    type=string
    ...    description=The kubectl command to run and retreive stdout from.
    ...    pattern=\w*
    ...    example=kubectl get pods --context my-context -n my-namespace
    ${DISTRIBUTION}=    RW.Core.Import User Variable    DISTRIBUTION
    ...    type=string
    ...    description=Which distribution of Kubernetes to use for operations, such as: Kubernetes, OpenShift, etc.
    ...    pattern=\w*
    ...    enum=[Kubernetes,GKE,OpenShift]
    ...    example=Kubernetes
    ...    default=Kubernetes
    Set Suite Variable    ${kubeconfig}    ${kubeconfig}

*** Tasks ***
Running Kubectl And Adding Stdout To Report
    ${stdout}=    RW.K8s.Shell
    ...    cmd=${KUBECTL_COMMAND}
    ...    target_service=${kubectl}
    ...    kubeconfig=${KUBECONFIG}
    ${history}=    RW.K8s.Pop Shell History
    ${history}=    RW.Utils.List To String    data_list=${history}
    RW.Core.Add Pre To Report    ${stdout}
    RW.Core.Add Pre To Report    Commands Used: ${history}
