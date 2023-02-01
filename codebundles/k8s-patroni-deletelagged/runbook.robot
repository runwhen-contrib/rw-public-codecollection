*** Settings ***
Metadata          Author    Jonathan Funk
Documentation     Uses kubectl (or equivalent) to query the state of a patroni cluster and determine if it's healthy.
Force Tags        K8s    Kubernetes    Kube    K8    Patroni    Health
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
    ...    example=1
    ...    default=1
    ${DOC_LINK}=    RW.Core.Import User Variable    CONTEXT
    ...    type=string
    ...    description=A URL to provide for followup docs in the report.
    ...    pattern=\w*
    ...    example=https://my-awesome-teamdocs-for-patroni.com
    ...    default=
    ${binary_name}=    RW.K8s.Get Binary Name    ${DISTRIBUTION}
    Set Suite Variable    ${binary_name}    ${binary_name}
    Set Suite Variable    ${kubeconfig}    ${kubeconfig}

*** Tasks ***
Determine Patroni Health
    ${stdout}=    RW.K8s.Shell
    ...    cmd=${binary_name} exec ${PATRONI_RESOURCE_NAME} -n ${NAMESPACE} --context ${CONTEXT} -it -- patronictl list -e -f yaml
    ...    target_service=${kubectl}
    ...    kubeconfig=${kubeconfig}
    ${state_yaml}=    RW.Utils.Yaml To Dict    yaml_str=${stdout}
    ${most_lagged_member}=    RW.Patroni.K8s Patroni Get Max Lag Member    state=${state_yaml}    min_lag=${LAG_TOLERANCE}
    ${dlt_cmd}=    RW.Patroni.K8s Patroni Template Deletemember
    ...    member_name=${most_lagged_member}
    ...    namespace=${NAMESPACE}
    ...    context=${CONTEXT}
    Run Keyword If    ${dlt_cmd} == ''    RW.Core.Add To Report    Did not find a replica to delete!
    Run Keyword If    ${dlt_cmd} != ''    RW.Core.Add To Report    Running the following command to delete a lagging replica:
    Run Keyword If    ${dlt_cmd} != ''    RW.Core.Add Code To Report    ${dlt_cmd}
    # Run Keyword If    ${dlt_cmd} != ''    RW.K8s.Shell
    # ...    cmd=${dlt_cmd}
    # ...    target_service=${kubectl}
    # ...    kubeconfig=${kubeconfig}
    RW.Core.Add To Report    If you're still having issues with Patroni after this has run, please refer to ${DOC_LINK}
    ${history}=    RW.K8s.Pop Shell History
    ${history}=    RW.Utils.List To String    data_list=${history}
    RW.Core.Add Pre To Report    Command History:\n${history}

