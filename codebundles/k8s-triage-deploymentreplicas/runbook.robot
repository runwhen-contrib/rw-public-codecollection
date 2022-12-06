*** Settings ***
Metadata          Author    Jonathan Funk
Documentation     Triages issues related to a deployment's replicas.
Force Tags        K8s    Kubernetes    Kube    K8    Triage    Troubleshoot    Deployment    Set    Pods    Replicas
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
    ${RESOURCE_NAME}=    RW.Core.Import User Variable    RESOURCE_NAME
    ...    type=string
    ...    description=Used to target the resource for queries and filtering events.
    ...    pattern=\w*
    ...    example=deployment/artifactory
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
Fetch Logs
    ${stdout}=    RW.K8s.Shell
    ...    cmd=${binary_name} logs --tail=100 ${RESOURCE_NAME} --context ${CONTEXT} -n ${NAMESPACE}
    ...    target_service=${kubectl}
    ...    kubeconfig=${KUBECONFIG}
    ${history}=    RW.K8s.Pop Shell History
    ${history}=    RW.Utils.List To String    data_list=${history}
    RW.Core.Add Pre To Report    ${stdout}
    RW.Core.Add Pre To Report    Commands Used: ${history}

Get Related Events
    ${stdout}=    RW.K8s.Shell
    ...    cmd=${binary_name} get events --context ${CONTEXT} -n ${NAMESPACE} | grep -i ${EVENT_SEARCH}
    ...    target_service=${kubectl}
    ...    kubeconfig=${KUBECONFIG}
    ${history}=    RW.K8s.Pop Shell History
    ${history}=    RW.Utils.List To String    data_list=${history}
    RW.Core.Add Pre To Report    ${stdout}
    RW.Core.Add Pre To Report    Commands Used: ${history}

Check Deployment Replicas
    ${stdout}=    RW.K8s.Shell
    ...    cmd=${binary_name} get ${RESOURCE_NAME} --context ${CONTEXT} -n ${NAMESPACE} -oyaml
    ...    target_service=${kubectl}
    ...    kubeconfig=${KUBECONFIG}
    ${deployment}=    RW.Utils.Yaml To Dict    ${stdout}
    ${stdout}=    RW.K8s.Shell
    ...    cmd=${binary_name} get hpa --context ${CONTEXT} -n ${NAMESPACE} -oyaml
    ...    target_service=${kubectl}
    ...    kubeconfig=${KUBECONFIG}
    ${hpas}=    RW.Utils.Yaml To Dict    ${stdout}
    ${has_hpa}=    RW.K8s.Has Hpa    hpas=${hpas}    deployment=${deployment}
    ${running_pod_count}=    RW.K8s.Get Available Replicas    ${deployment}
    ${desired_pod_count}=    RW.K8s.Get Desired Replicas    ${deployment}
    ${healthy_state}=    Evaluate    bool(${running_pod_count} == ${desired_pod_count})
    RW.Core.Add Pre To Report    The deployment is healthy (correct number of running replicas): ${healthy_state}
    ${is_ha}=    Evaluate    bool(${running_pod_count} > 3)
    ${remediation_msg}=    RW.Utils.String If Else
    ...    check_boolean=${is_ha}
    ...    if_str=Run to perform rollout: ${binary_name} rollout restart ${RESOURCE_NAME} --context ${CONTEXT} -n ${NAMESPACE}
    ...    else_str=The resource ${RESOURCE_NAME} may not be highly available, please manually review it to avoid downtime!
    RW.Core.Add Pre To Report    The resource is Highly Available: ${is_ha}
    RW.Core.Add Pre To Report    HorizontalPodAutoscaler detected: ${has_hpa}
    RW.Core.Add Pre To Report    Next steps for remediation:\n\t${remediation_msg}
    ${history}=    RW.K8s.Pop Shell History
    ${history}=    RW.Utils.List To String    data_list=${history}
    RW.Core.Add Pre To Report    Commands Used: ${history}
