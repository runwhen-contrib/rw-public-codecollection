*** Settings ***
Documentation       This codebundle runs a kubectl get command that produces a value and pushes the metric.
...                 Uses jmespath for filtering and allows calculations such as count, sum, avg on specified fields.
Metadata            Author    Shea Stewart

Library             RW.Core
Library             RW.K8s
Library             RW.K8s.K8sUtils
Library             RW.Utils
Library             RW.platform

Suite Setup         Suite Initialization

Force Tags          k8s    kubernetes    kube    k8    kubectl    stdout    command    run


*** Tasks ***
Running Kubectl get and push the metric
    ${stdout_json}=    RW.K8s.Shell
    ...    cmd=${KUBECTL_COMMAND} -o json
    ...    target_service=${kubectl}
    ...    kubeconfig=${KUBECONFIG}
    ${metric}=    RW.K8s.K8sUtils.Convert to metric
    ...    data=${stdout_json}
    ...    search_filter=${SEARCH_FILTER}
    ...    calculation_field=${CALCULATION_FIELD}
    ...    calculation=${CALCULATION}
    RW.Core.Push Metric    ${metric}


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
    ${KUBECTL_COMMAND}=    RW.Core.Import User Variable    KUBECTL_COMMAND
    ...    type=string
    ...    description=The kubectl command to run and retreive stdout from.
    ...    pattern=\w*
    ...    example="kubectl get pods -n my-namespace"
    ${CALCULATION}=    RW.Core.Import User Variable    CALCULATION
    ...    type=string
    ...    description=The type of calualation to perform
    ...    enum=["Count", "Sum", "Average"]
    ${CALCULATION_FIELD}=    RW.Core.Import User Variable    CALCULATION_FIELD
    ...    type=string
    ...    pattern=\w*
    ...    description=The field or property to perform calculation with if using sum or average.
    ...    example="status.containerStatuses[].restartCount"
    ${SEARCH_FILTER}=    RW.Core.Import User Variable    SEARCH_FILTER
    ...    type=string
    ...    pattern=\w*
    ...    description=A filter to apply to the search results. Note: Use backticks in text filtering.
    ...    example=status.phase==`Running`
    ${DISTRIBUTION}=    RW.Core.Import User Variable    DISTRIBUTION
    ...    type=string
    ...    description=Which distribution of Kubernetes to use for operations, such as: Kubernetes, OpenShift, etc.
    ...    pattern=\w*
    ...    enum=[Kubernetes,GKE,OpenShift]
    ...    example=Kubernetes
    ...    default=Kubernetes
    Set Suite Variable    ${kubeconfig}    ${kubeconfig}
