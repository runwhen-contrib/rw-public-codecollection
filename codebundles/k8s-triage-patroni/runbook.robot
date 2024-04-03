*** Settings ***
Metadata          Author    Jonathan Funk
Metadata          Display Name    Kubernetes Triage Patroni
Metadata          Supports    Kubernetes,AKS,EKS,GKE,OpenShift,Patroni,PostgreSQL
Documentation     Taskset to triage issues related to patroni.
Force Tags        K8s    Kubernetes    Kube    K8    Triage    Troubleshoot    Patroni
Suite Setup       Suite Initialization
Library           BuiltIn
Library           RW.Core
Library           RW.Utils
Library           RW.K8s
Library           RW.platform
Library           OperatingSystem

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
    ${RESOURCE_NAME}=    RW.Core.Import User Variable    RESOURCE_NAME
    ...    type=string
    ...    description=Used to target the resource for queries and filtering events.
    ...    pattern=\w*
    ...    example=statefulset/my-patroni
    ${NAMESPACE}=    RW.Core.Import User Variable    NAMESPACE
    ...    type=string
    ...    description=The name of the Kubernetes namespace to scope actions and searching to.
    ...    pattern=\w*
    ...    example=my-namespace
    ${CONTEXT}=    RW.Core.Import User Variable    CONTEXT
    ...    type=string
    ...    description=Which Kubernetes context to operate within.
    ...    pattern=\w*
    ...    example=my-main-cluster
    ${LABELS}=    RW.Core.Import User Variable    LABELS
    ...    type=string
    ...    description=A Kubernetes label selector string used to filter/find relevant resources for troubleshooting.
    ...    pattern=\w*
    ...    example=Could not render example.
    ${DISTRIBUTION}=    RW.Core.Import User Variable    DISTRIBUTION
    ...    type=string
    ...    description=Which distribution of Kubernetes to use for operations, such as: Kubernetes, OpenShift, etc.
    ...    pattern=\w*
    ...    enum=[Kubernetes,GKE,OpenShift]
    ...    example=Kubernetes
    ${binary_name}=    RW.K8s.Get Binary Name    ${DISTRIBUTION}
    Set Suite Variable    ${binary_name}    ${binary_name}
    Set Suite Variable    ${kubeconfig}    ${kubeconfig}

*** Tasks ***
Get Patroni Status
    ${stdout}=    RW.K8s.Shell
    ...    cmd=${binary_name} exec ${RESOURCE_NAME} -n ${NAMESPACE} --context ${CONTEXT} -it -- patronictl list
    ...    target_service=${kubectl}
    ...    kubeconfig=${KUBECONFIG}
    ${history}=    RW.K8s.Pop Shell History
    ${history}=    RW.Utils.List To String    data_list=${history}
    RW.Core.Add Pre To Report    ${stdout}
    RW.Core.Add Pre To Report    Commands Used: ${history}

Get Pods Status
    ${stdout}=    RW.K8s.Shell
    ...    cmd=${binary_name} get pods --selector=${LABELS} --context ${CONTEXT} -n ${NAMESPACE}
    ...    target_service=${kubectl}
    ...    kubeconfig=${KUBECONFIG}
    ${history}=    RW.K8s.Pop Shell History
    ${history}=    RW.Utils.List To String    data_list=${history}
    RW.Core.Add Pre To Report    ${stdout}
    RW.Core.Add Pre To Report    Commands Used: ${history}

Fetch Logs
    ${stdout}=    RW.K8s.Shell
    ...    cmd=${binary_name} logs --tail=100 ${RESOURCE_NAME} --context ${CONTEXT} -n ${NAMESPACE}
    ...    target_service=${kubectl}
    ...    kubeconfig=${KUBECONFIG}
    ${history}=    RW.K8s.Pop Shell History
    ${history}=    RW.Utils.List To String    data_list=${history}
    RW.Core.Add Pre To Report    ${stdout}
    RW.Core.Add Pre To Report    Commands Used: ${history}
