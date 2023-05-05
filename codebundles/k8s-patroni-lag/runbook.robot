*** Settings ***
Metadata          Author    Jonathan Funk
Documentation     Detects and reinitializes laggy Patroni cluster members which are unable to catchup in replication using kubectl and patronictl.
Force Tags        K8s    Kubernetes    Kube    K8    Patroni    Health    Reinitialize    Lag    patronictl
Suite Setup       Suite Initialization
Library           BuiltIn
Library           RW.Core
Library           RW.Utils
Library           RW.K8s
Library           RW.Patroni
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
    ${PATRONI_RESOURCE_NAME}=    RW.Core.Import User Variable    PATRONI_RESOURCE_NAME
    ...    type=string
    ...    description=Determine which object is queried for information to determine the action taken, if any.
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
    ${DISTRIBUTION}=    RW.Core.Import User Variable    DISTRIBUTION
    ...    type=string
    ...    description=Which distribution of Kubernetes to use for operations, such as: Kubernetes, OpenShift, etc.
    ...    pattern=\w*
    ...    enum=[Kubernetes,GKE,OpenShift]
    ...    example=Kubernetes
    ${LAG_TOLERANCE}=    RW.Core.Import User Variable    LAG_TOLERANCE
    ...    type=string
    ...    description=Replica(s) beyond this threshold will be deleted. Value represents MB akin to the output of 'patronictl list'.
    ...    pattern=^\d+$
    ...    example=5
    ...    default=5
    ${DOC_LINK}=    RW.Core.Import User Variable    DOC_LINK
    ...    type=string
    ...    description=A URL to provide for followup docs in the report.
    ...    pattern=\w*
    ...    example=https://my-awesome-teamdocs-for-patroni.com
    ...    default=
    ${binary_name}=    RW.K8s.Get Binary Name    ${DISTRIBUTION}
    Set Suite Variable    ${binary_name}    ${binary_name}
    Set Suite Variable    ${kubeconfig}    ${kubeconfig}
    Set Suite Variable    ${kubectl}    ${kubectl}
    Set Suite Variable    ${NAMESPACE}    ${NAMESPACE}
    Set Suite Variable    ${CONTEXT}    ${CONTEXT}
    Set Suite Variable    ${PATRONI_RESOURCE_NAME}    ${PATRONI_RESOURCE_NAME}
    Set Suite Variable    ${LAG_TOLERANCE}    ${LAG_TOLERANCE}
    Set Suite Variable    ${DOC_LINK}    ${DOC_LINK}

*** Tasks ***
Determine Patroni Health
    ${stdout}=    RW.K8s.Shell
    ...    cmd=${binary_name} exec ${PATRONI_RESOURCE_NAME} -n ${NAMESPACE} --context ${CONTEXT} -it -- patronictl list -e -f yaml
    ...    target_service=${kubectl}
    ...    kubeconfig=${kubeconfig}
    ...    render_in_commandlist=true
    ${state_yaml}=    RW.Utils.Yaml To Dict    yaml_str=${stdout}
    ${cluster_name}=    RW.Patroni.K8s Patroni Get Cluster Name    state=${state_yaml}
    ${laggy_members}=    RW.Patroni.K8s Patroni Get Laggy Members    state=${state_yaml}    lag_tolerance=${LAG_TOLERANCE}
    Run Keyword If    len($laggy_members) == 0    RW.Core.Add To Report    Did not find a replica to delete!
    ${reinit_cmd}=    Run Keyword If    len($laggy_members) > 0    Set Variable    ${binary_name} exec ${PATRONI_RESOURCE_NAME} -n ${NAMESPACE} --context ${CONTEXT} -it -- patronictl reinit ${cluster_name} ${laggy_members[0]} --force
    Run Keyword If    len($laggy_members) > 0    RW.Core.Add To Report    Running the following command to delete a lagging replica:
    Run Keyword If    len($laggy_members) > 0    RW.Core.Add Code To Report    ${reinit_cmd}
    ${stdout}=    Run Keyword If    len($laggy_members) > 0    RW.K8s.Shell
    ...    cmd=${reinit_cmd}
    ...    target_service=${kubectl}
    ...    kubeconfig=${kubeconfig}
    Run Keyword If    len($laggy_members) > 0    RW.Core.Add To Report    Reinitializing member ${laggy_members[0]} in cluster ${cluster_name}
    Run Keyword If    len($laggy_members) > 0    RW.Core.Add To Report    ${stdout}
    ${stdout}=    RW.K8s.Shell
    ...    cmd=${binary_name} exec ${PATRONI_RESOURCE_NAME} -n ${NAMESPACE} --context ${CONTEXT} -it -- patronictl list -e -f yaml
    ...    target_service=${kubectl}
    ...    kubeconfig=${kubeconfig}
    ${state_yaml}=    RW.Utils.Yaml To Dict    yaml_str=${stdout}
    RW.Core.Add To Report    Post-run state:
    RW.Core.Add To Report    ${state_yaml}
    Run Keyword If    "${DOC_LINK}" != ""    RW.Core.Add To Report    If you're still having issues with Patroni after this has run, please refer to ${DOC_LINK}
    ${history}=    RW.K8s.Pop Shell History
    ${history}=    RW.Utils.List To String    data_list=${history}
    RW.Core.Add Pre To Report    Command History:\n${history}

