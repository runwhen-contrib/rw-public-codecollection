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
    ${RESOURCE_KINDS}=    RW.Core.Import User Variable    RESOURCE_KINDS
    ...    type=string
    ...    description=Which Kubernetes kinds to inspect during troubleshooting as a CSV. Depending on kinds and your cluster workloads this can increase codebundle runtime.
    ...    pattern=\w*
    ...    example=Deployment,DaemonSet,StatefulSet
    ...    default=Deployment,DaemonSet,StatefulSet
    ${DISTRIBUTION}=    RW.Core.Import User Variable    DISTRIBUTION
    ...    type=string
    ...    description=Which distribution of Kubernetes to use for operations, such as: Kubernetes, OpenShift, etc.
    ...    pattern=\w*
    ...    enum=[Kubernetes,GKE,OpenShift]
    ...    example=Kubernetes
    ...    default=Kubernetes
    ${ERROR_PATTERN}=    RW.Core.Import User Variable    ERROR_PATTERN
    ...    type=string
    ...    description=The error pattern to use when grep-ing logs.
    ...    pattern=\w*
    ...    example=(Error|Exception)
    ...    default=(Error|Exception)
    ${EVENT_AGE}=    RW.Core.Import User Variable    EVENT_AGE
    ...    type=string
    ...    description=The time window in minutes as to when the event was last seen.
    ...    pattern=((\d+?)m)?
    ...    example=30m
    ...    default=30m
    ${binary_name}=    RW.K8s.Get Binary Name    ${DISTRIBUTION}
    ${kinds_list}=    RW.utils.Csv To List    ${RESOURCE_KINDS}
    ${RESOURCE_KINDS}=    RW.utils.Remove Spaces   ${RESOURCE_KINDS}
    Set Suite Variable    ${binary_name}    ${binary_name}
    Set Suite Variable    ${kinds_list}    ${kinds_list}
    Set Suite Variable    ${kubeconfig}    ${kubeconfig}
    Set Suite Variable    ${kubectl}    ${kubectl}
    Set Suite Variable    ${CONTEXT}    ${CONTEXT}
    Set Suite Variable    ${NAMESPACE}    ${NAMESPACE}
    Set Suite Variable    ${ERROR_PATTERN}    ${ERROR_PATTERN}
    Set Suite Variable    ${RESOURCE_KINDS}    ${RESOURCE_KINDS}
    Set Suite Variable    ${EVENT_AGE}    ${EVENT_AGE}

*** Tasks ***
Trace Namespace Errors
    ${error_results}=    RW.K8s.Trace Namespace Errors
    ...    context=${CONTEXT}
    ...    namespace=${NAMESPACE}
    ...    target_service=${kubectl}
    ...    kubeconfig=${kubeconfig}
    ...    error_pattern=${ERROR_PATTERN}
    ...    event_age=${EVENT_AGE}
    ...    binary_name=${binary_name}
    ${history}=    RW.K8s.Pop Shell History
    ${history}=    RW.Utils.List To String    data_list=${history}
    RW.Core.Add Pre To Report    Summary of errors traced in namespace: ${NAMESPACE}
    RW.Core.Add Pre To Report    ${error_results}
    RW.Core.Add Pre To Report    Commands Used:\n${history}


*** Tasks ***
Fetch Unready Pods
    ${unreadypods_results}=    RW.K8s.Shell
    ...    cmd=${binary_name} get pods --context=${CONTEXT} -n ${NAMESPACE} --sort-by='status.containerStatuses[0].restartCount' --field-selector=status.phase!=Running,status.phase!=Succeeded
    ...    target_service=${kubectl}
    ...    kubeconfig=${kubeconfig}
    ${history}=    RW.K8s.Pop Shell History
    ${history}=    RW.Utils.List To String    data_list=${history}
    RW.Core.Add Pre To Report    Summary of unhealthy pod restarts in namespace: ${NAMESPACE}
    RW.Core.Add Pre To Report    ${unreadypods_results}
    RW.Core.Add Pre To Report    Commands Used:\n${history}


Triage Namespace
    #TODO: Paginated Shell
    ${troubleshoot_report}=    RW.K8s.Triage Namespace
    ...    resource_kinds=${RESOURCE_KINDS}
    ...    namespace=${NAMESPACE}
    ...    context=${CONTEXT}
    ...    kubeconfig=${kubeconfig}
    ...    target_service=${kubectl}
    ...    binary_name=${binary_name}
    ${history}=    RW.K8s.Pop Shell History
    ${history}=    RW.Utils.List To String    data_list=${history}
    RW.Core.Add Pre To Report    ${troubleshoot_report}
    RW.Core.Add Pre To Report    Commands Used:\n${history}
