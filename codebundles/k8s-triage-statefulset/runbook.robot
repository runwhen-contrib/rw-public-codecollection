*** Settings ***
Metadata          Author    Jonathan Funk
Documentation     A taskset for troubleshooting issues for StatefulSets and their related resources.
Force Tags        K8s    Kubernetes    Kube    K8    Triage    Troubleshoot    Statefulset    Set    Pods
Suite Setup       Suite Initialization
Library           BuiltIn
Library           RW.Core
Library           RW.K8s
Library           RW.platform
Library           OperatingSystem

*** Keywords ***
Suite Initialization
    ${kubeconfig}=    RW.Core.Import Secret    kubeconfig
    ${kubectl}=    RW.Core.Import Service    kubectl
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
    ${rsp}=    RW.K8s.Get
    ...    kind=StatefulSet
    ...    namespace=${NAMESPACE}
    ...    context=${CONTEXT}
    ...    kubeconfig=${kubeconfig}
    ...    unpack_from_items=True
    ...    labels=${LABELS}
    ...    distribution=${DISTRIBUTION}
    ${all_ready}=    RW.K8s.Stateful Sets Ready
    ...    statefulsets=${rsp}
    ...    unpack_from_items=False
    RW.Core.Add Pre To Report    All StatefulSets Replicas Ready: ${all_ready}
    ${command}=    Set Variable    ${binary_name} get statefulsets -l ${LABELS} --context ${CONTEXT} -n ${NAMESPACE}
    ${rsp}=    RW.K8s.Kubectl
    ...    cmd=${command}
    ...    target_service=${kubectl}
    ...    kubeconfig=${kubeconfig}
    ${stdout}=    Set Variable    ${rsp.stdout}
    RW.Core.Add Pre To Report    Command Used: ${command}
    RW.Core.Add Pre To Report    ${stdout}

Get Events For The StatefulSet
    ${command}=    Set Variable    ${binary_name} get events --context ${CONTEXT} -n ${NAMESPACE} | grep -i ${EVENT_SEARCH}
    ${rsp}=    RW.K8s.Kubectl
    ...    cmd=${command}
    ...    target_service=${kubectl}
    ...    kubeconfig=${kubeconfig}
    ${stdout}=    Set Variable    ${rsp.stdout}
    RW.Core.Add Pre To Report    Command Used: ${command}
    RW.Core.Add Pre To Report    ${stdout}

Get StatefulSet Logs
    ${command}=    Set Variable    ${binary_name} get statefulsets -l ${LABELS} --no-headers -o custom-columns=":metadata.name" --context ${CONTEXT} -n ${NAMESPACE} | xargs -I '{ss}' ${binary_name} logs --tail=100 statefulset/{ss} --context ${CONTEXT} -n ${NAMESPACE}
    ${rsp}=    RW.K8s.Kubectl
    ...    cmd=${command}
    ...    target_service=${kubectl}
    ...    kubeconfig=${kubeconfig}
    ${stdout}=    Set Variable    ${rsp.stdout}
    RW.Core.Add Pre To Report    Command Used: ${command}
    RW.Core.Add Pre To Report    ${stdout}

Get StatefulSet Manifests Dump
    ${rsp}=    RW.K8s.Get
    ...    kind=StatefulSet
    ...    kubeconfig=${kubeconfig}
    ...    target_service=${kubectl}
    ...    context=${CONTEXT}
    ...    namespace=${NAMESPACE}
    ...    labels=${LABELS}
    ...    output_format=yaml
    ...    distribution=${DISTRIBUTION}
    RW.Core.Add Pre To Report    ${rsp}
