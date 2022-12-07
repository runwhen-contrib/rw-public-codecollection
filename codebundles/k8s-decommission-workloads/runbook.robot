*** Settings ***
Metadata          Author    Jonathan Funk
Documentation     Searches a namespace for matching objects and provides the commands to decommission them.
Force Tags        K8s    Workloads    Decommission    Delete    Cleanup
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
    ${SEARCH_FOR}=    RW.Core.Import User Variable    SEARCH_FOR
    ...    type=string
    ...    description=A string value to scan all objects for in a namespace and identify for deletion. They are not deleted automatically.
    ...    pattern=\w*
    ...    example=myoldservice
    ${binary_name}=    RW.K8s.Get Binary Name    ${DISTRIBUTION}
    Set Suite Variable    ${binary_name}    ${binary_name}
    Set Suite Variable    ${kubeconfig}    ${kubeconfig}

*** Tasks ***
Generate Decomission Commands
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
    ${list_of_k8s_objects}=    RW.K8s.Get Objects By Name
    ...    names=${object_names}
    ...    namespace=${NAMESPACE}
    ...    context=${CONTEXT}
    ...    target_service=${kubectl}
    ...    kubeconfig=${kubeconfig}
    ${found_in_objects}=    RW.K8s.Search Namespace Objects For String
    ...    k8s_items=${list_of_k8s_objects}
    ...    search_string=${SEARCH_FOR}
    ${found_names}=    RW.K8s.Get Object Names
    ...    k8s_items=${found_in_objects}
    ...    distinct_values=True
    ${delete_cmds}=    RW.Utils.Templated String List
    ...    template_string=${binary_name} delete {item} --context=${CONTEXT} --namespace=${NAMESPACE}
    ...    values=${found_names}
    ${decomission_commands}=    RW.Utils.List To String    data_list=${delete_cmds}
    ${history}=    RW.K8s.Pop Shell History
    ${history}=    RW.Utils.List To String    data_list=${history}
    ${found_names}=    RW.Utils.List To String    data_list=${found_names}
    RW.Core.Add Pre To Report    Objects to decomission:\n${found_names}
    RW.Core.Add Pre To Report    Decomission commands:\n${decomission_commands}
    RW.Core.Add Pre To Report    Commands Used:\n${history}
