*** Settings ***
Documentation       This codebundle runs a series of tasks to identify potential helm release issues.
Metadata            Author    Shea Stewart
Metadata            Canonical Name    Kubernetes Helm TaskSet
Metadata            Supports    Kubernetes,AKS,EKS,GKE,OpenShift,FluxCD
Library             RW.Core
Library             RW.K8s
Library             RW.K8s.K8sUtils
Library             RW.Utils
Library             RW.platform

Suite Setup         Suite Initialization

Force Tags          k8s    kubernetes    kube    k8    kubectl    stdout    command    run    helm    flux


*** Tasks ***
List all available Helmreleases    
    ${stdout}=    RW.K8s.Shell
    ...    cmd=${binary_name} get helmreleases --all-namespaces --context ${context}
    ...    target_service=${kubectl}
    ...    kubeconfig=${KUBECONFIG}
    ${history}=    RW.K8s.Pop Shell History
    ${history}=    RW.Utils.List To String    data_list=${history}
    RW.Core.Add Pre To Report    Helmreleases available: \n ${stdout}

Fetch All HelmRelease Versions  
    ${stdout}=    RW.K8s.Shell
    ...    cmd=${binary_name} get helmreleases --all-namespaces -o=jsonpath="{range .items[*]}{'\\nName: '}{@.metadata.name}{'\\nlastAppliedRevision:'}{@.status.lastAppliedRevision}{'\\nlastAttemptedRevision:'}{@.status.lastAttemptedRevision}{'\\n---'}" --context ${context}
    ...    target_service=${kubectl}
    ...    kubeconfig=${KUBECONFIG}
    ${history}=    RW.K8s.Pop Shell History
    ${history}=    RW.Utils.List To String    data_list=${history}
    RW.Core.Add Pre To Report    Helmreleases status errors: \n ${stdout}

Fetch Mismatched HelmRelease Version
    ${stdout}=    RW.K8s.Shell
    ...    cmd=${binary_name} get helmreleases --all-namespaces -o json --context ${context} | jq -r '.items[] | select(.status.lastAppliedRevision!=.status.lastAttemptedRevision) | "Name: " + .metadata.name + " Last Attempted Version: " + .status.lastAttemptedRevision + " Last Applied Revision: " + .status.lastAppliedRevision'
    ...    target_service=${kubectl}
    ...    kubeconfig=${KUBECONFIG}
    ${history}=    RW.K8s.Pop Shell History
    ${history}=    RW.Utils.List To String    data_list=${history}
    RW.Core.Add Pre To Report    Helmreleases status errors: \n ${stdout}

Fetch HelmRelease Error Conditions    
    ${stdout}=    RW.K8s.Shell
    ...    cmd=${binary_name} get helmreleases --all-namespaces -o=jsonpath="{range .items[?(@.status.conditions[].status=='False')]}{'-----\\nName: '}{@.metadata.name}{'\\n'}{@.status.conditions[*].message}{'\\n'}" --context ${context}
    ...    target_service=${kubectl}
    ...    kubeconfig=${KUBECONFIG}
    ${history}=    RW.K8s.Pop Shell History
    ${history}=    RW.Utils.List To String    data_list=${history}
    RW.Core.Add Pre To Report    Helmreleases status errors: \n ${stdout}


*** Keywords ***
Suite Initialization
    ${kubeconfig}=    RW.Core.Import Secret
    ...    kubeconfig
    ...    type=string
    ...    description=The kubernetes kubeconfig yaml containing connection configuration used to connect to cluster(s).
    ...    pattern=\w*
    ...    example=For examples, start here https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/
    ${kubectl}=    RW.Core.Import Service    kubectl
    ...    description=The location service used to interpret shell commands.
    ...    default=kubectl-service.shared
    ...    example=kubectl-service.shared
    ${DISTRIBUTION}=    RW.Core.Import User Variable    DISTRIBUTION
    ...    type=string
    ...    description=Which distribution of Kubernetes to use for operations, such as: Kubernetes, OpenShift, etc.
    ...    pattern=\w*
    ...    enum=[Kubernetes,GKE,OpenShift]
    ...    example=Kubernetes
    ...    default=Kubernetes
    ${binary_name}=    RW.K8s.Get Binary Name    ${DISTRIBUTION}
    ${CONTEXT}=    RW.Core.Import User Variable    CONTEXT
    ...    type=string
    ...    description=Which Kubernetes context to operate within.
    ...    pattern=\w*
    ...    default=default
    ...    example=my-main-cluster
    Set Suite Variable    ${binary_name}    ${binary_name}
    Set Suite Variable    ${kubeconfig}    ${kubeconfig}
