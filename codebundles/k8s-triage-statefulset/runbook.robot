*** Settings ***
Metadata          Author    Jonathan Funk
Metadata          Display Name    Kubernetes Triage StatefulSet
Metadata          Supports    Kubernetes,AKS,EKS,GKE,OpenShift
Documentation     A taskset for troubleshooting issues for StatefulSets and their related resources.
Force Tags        K8s    Kubernetes    Kube    K8    Triage    Troubleshoot    Statefulset    Set    Pods
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
    ${EVENT_SEARCH}=    RW.Core.Import User Variable    EVENT_SEARCH
    ...    type=string
    ...    description=Grep events for the following search term.
    ...    pattern=\w*
    ...    example=artifactory
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
Check StatefulSets Replicas Ready
    ${stdout}=    RW.K8s.Shell
    ...    cmd=${binary_name} get statefulset --selector=${LABELS} --context=${CONTEXT} --namespace=${NAMESPACE} -o yaml
    ...    target_service=${kubectl}
    ...    kubeconfig=${KUBECONFIG}
    ${statefulsets}=    RW.Utils.Yaml To Dict    ${stdout}
    ${all_ready}=    RW.K8s.Stateful Sets Ready
    ...    statefulsets=${statefulsets}
    RW.Core.Add Pre To Report    All StatefulSets Replicas Ready: ${all_ready}
    ${stdout}=    RW.K8s.Shell
    ...    cmd=${binary_name} get statefulset --selector=${LABELS} --context=${CONTEXT} --namespace=${NAMESPACE}
    ...    target_service=${kubectl}
    ...    kubeconfig=${KUBECONFIG}
    ${history}=    RW.K8s.Pop Shell History
    ${history}=    RW.Utils.List To String    data_list=${history}
    RW.Core.Add Pre To Report    ${stdout}
    RW.Core.Add Pre To Report    Commands Used: ${history}

Get Events For The StatefulSet
    ${stdout}=    RW.K8s.Shell
    ...    cmd=${binary_name} get events --context ${CONTEXT} -n ${NAMESPACE} | grep -i ${EVENT_SEARCH}
    ...    target_service=${kubectl}
    ...    kubeconfig=${KUBECONFIG}
    ${history}=    RW.K8s.Pop Shell History
    ${history}=    RW.Utils.List To String    data_list=${history}
    RW.Core.Add Pre To Report    ${stdout}
    RW.Core.Add Pre To Report    Commands Used: ${history}

Get StatefulSet Logs
    ${stdout}=    RW.K8s.Shell
    ...    cmd=${binary_name} get statefulsets -l ${LABELS} --no-headers -o custom-columns=":metadata.name" --context ${CONTEXT} -n ${NAMESPACE} | xargs -I '{ss}' ${binary_name} logs --tail=100 statefulset/{ss} --context ${CONTEXT} -n ${NAMESPACE}
    ...    target_service=${kubectl}
    ...    kubeconfig=${KUBECONFIG}
    RW.Core.Add Pre To Report    ${stdout}
    ${history}=    RW.K8s.Pop Shell History
    ${history}=    RW.Utils.List To String    data_list=${history}
    RW.Core.Add Pre To Report    Commands Used: ${history}

Get StatefulSet Manifests Dump
    ${stdout}=    RW.K8s.Shell
    ...    cmd=${binary_name} get statefulset --selector=${LABELS} --context=${CONTEXT} --namespace=${NAMESPACE} -o yaml
    ...    target_service=${kubectl}
    ...    kubeconfig=${KUBECONFIG}
    ${history}=    RW.K8s.Pop Shell History
    ${history}=    RW.Utils.List To String    data_list=${history}
    RW.Core.Add Pre To Report    ${stdout}
    RW.Core.Add Pre To Report    Commands Used: ${history}
