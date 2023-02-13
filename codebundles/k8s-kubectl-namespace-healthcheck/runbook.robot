*** Settings ***
Metadata          Author    Jonathan Funk
Documentation     This taskset runs general troubleshooting checks against all applicable objects in a namespace, checks error events, and searches pod logs for error entries.
Force Tags        K8s    Kubernetes    Kube    K8
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
    ${DISTRIBUTION}=    RW.Core.Import User Variable    DISTRIBUTION
    ...    type=string
    ...    description=Which distribution of Kubernetes to use for operations, such as: Kubernetes, OpenShift, etc.
    ...    pattern=\w*
    ...    enum=[Kubernetes,GKE,OpenShift]
    ...    example=Kubernetes
    ${ERROR_PATTERN}=    RW.Core.Import User Variable    ERROR_PATTERN
    ...    type=string
    ...    description=The error pattern to use when grep-ing logs.
    ...    pattern=\w*
    ...    example=(Error|Exception)
    ...    default=(Error|Exception)
    ${binary_name}=    RW.K8s.Get Binary Name    ${DISTRIBUTION}
    Set Suite Variable    ${binary_name}    ${binary_name}

*** Tasks ***
Troubleshoot Namespace
    ${stdout}=    RW.K8s.Shell
    ...    cmd=kubectl api-resources --verbs=list --namespaced --context=${CONTEXT} --namespace=${NAMESPACE} -o name
    ...    target_service=${kubectl}
    ...    kubeconfig=${kubeconfig}
    ${resource_types}=    RW.Utils.Stdout To List    stdout=${stdout}
    ${object_names}=    RW.K8s.Loop Template Shell
    ...    items=${resource_types}
    ...    cmd=kubectl get {item} --no-headers --show-kind --ignore-not-found --context=${CONTEXT} --namespace=${NAMESPACE} -o name
    ...    target_service=${kubectl}
    ...    kubeconfig=${kubeconfig}
    ...    newline_as_separate=True
    ${ts_results}=    RW.K8s.Check Namespace Objects
    ...    k8s_object_names=${object_names}
    ...    context=${CONTEXT}
    ...    namespace=${NAMESPACE}
    ...    target_service=${kubectl}
    ...    kubeconfig=${kubeconfig}
    ${history}=    RW.K8s.Pop Shell History
    ${history}=    RW.Utils.List To String    data_list=${history}
    RW.Core.Add Pre To Report    ${ts_results}
    RW.Core.Add Pre To Report    Commands Used:\n${history}

Find Namespace Errors
    ${error_results}=    RW.K8s.Check Namespace Errors
    ...    context=${CONTEXT}
    ...    namespace=${NAMESPACE}
    ...    target_service=${kubectl}
    ...    kubeconfig=${kubeconfig}
    ...    error_pattern=${ERROR_PATTERN}
    ${history}=    RW.K8s.Pop Shell History
    ${history}=    RW.Utils.List To String    data_list=${history}
    RW.Core.Add Pre To Report    ${error_results}
    RW.Core.Add Pre To Report    Commands Used:\n${history}
