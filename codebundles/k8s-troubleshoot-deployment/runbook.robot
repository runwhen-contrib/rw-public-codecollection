*** Settings ***
Metadata          Author    Jonathan Funk
Documentation     A taskset for troubleshooting general issues associated with typical kubernetes deployment resources.
...               Supports API interactions via both the API client and Kubectl binary through RunWhen Shell Services.
Force Tags        K8s    Kubernetes    Kube    K8
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
    ${NAME}=    RW.Core.Import User Variable    NAME
    ...    type=string
    ...    description=The name of the Kubernetes resources to search for. Partial matches are supported.
    ...    pattern=\w*
    ...    example=my-api
    ${LABELS}=    RW.Core.Import User Variable    LABELS
    ...    type=string
    ...    description=A Kubernetes label selector string used to filter/find relevant resources for troubleshooting.
    ...    pattern=\w*
    ...    example=Could not render example.
    ${MUTE_SUGGESTIONS}=    RW.Core.Import User Variable    MUTE_SUGGESTIONS
    ...    type=string
    ...    enum=[Yes,No]
    ...    description=Whether or not helpful suggestions and documentation links are included in the reports.
    ...    default=No
    ${RESOURCING_DOCS}=    RW.Core.Import User Variable    RESOURCING_DOCS
    ...    type=string
    ...    description=Which link to direct users to for documentation on Kubernetes resourcing.
    ...    pattern=\w*
    ...    default=https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/
    ${PODDISRUPTIONBUDGET_DOCS}=    RW.Core.Import User Variable    PODDISRUPTIONBUDGET_DOCS
    ...    type=string
    ...    description=Which link to direct users to for documentation on Kubernetes pod disruption budgets.
    ...    pattern=\w*
    ...    default=https://kubernetes.io/docs/tasks/run-application/configure-pdb/
    ${EVENTS_DOCS}=    RW.Core.Import User Variable    EVENTS_DOCS
    ...    type=string
    ...    description=Which link to direct users to for documentation on Kubernetes events.
    ...    pattern=\w*
    ...    default=https://kubernetes.io/docs/reference/kubernetes-api/cluster-resources/event-v1/

*** Tasks ***
Troubleshoot Resourcing
    ${rsp}=    RW.K8s.Check Resources
    ...    kubeconfig=${KUBECONFIG}
    ...    target_service=${kubectl}
    ...    context=${CONTEXT}
    ...    namespace=${NAMESPACE}
    ...    search_name=${NAME}
    ...    labels=${LABELS}
    ...    distribution=${DISTRIBUTION}
    ${resource_report}=    RW.K8s.Format Resources Report
    ...    report_data=${rsp}
    ...    search_name=${NAME}
    ...    resource_doc_link=https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/
    ...    mute_suggestions=${MUTE_SUGGESTIONS}
    RW.Core.Add Pre To Report    ${resource_report}

Troubleshoot Events
    ${rsp}=    RW.K8s.Check Events
    ...    kubeconfig=${KUBECONFIG}
    ...    target_service=${kubectl}
    ...    context=${CONTEXT}
    ...    namespace=${NAMESPACE}
    ...    search_name=${NAME}
    ...    distribution=${DISTRIBUTION}
    ${events_report}=    RW.K8s.Format Events Report
    ...    report_data=${rsp}
    ...    search_name=${NAME}
    ...    events_doc_link=https://kubernetes.io/docs/reference/kubernetes-api/cluster-resources/event-v1/
    ...    mute_suggestions=${MUTE_SUGGESTIONS}
    RW.Core.Add Pre To Report    ${events_report}

Troubleshoot PVC
    ${rsp}=    RW.K8s.Check PVC
    ...    kubeconfig=${KUBECONFIG}
    ...    target_service=${kubectl}
    ...    context=${CONTEXT}
    ...    namespace=${NAMESPACE}
    ...    search_name=${NAME}
    ...    distribution=${DISTRIBUTION}
    ${events_report}=    RW.K8s.Format PVC Report
    ...    report_data=${rsp}
    ...    search_name=${NAME}
    ...    mute_suggestions=${MUTE_SUGGESTIONS}
    RW.Core.Add Pre To Report    ${events_report}

Troubleshoot Pods
    ${rsp}=    RW.K8s.Check Pods
    ...    kubeconfig=${KUBECONFIG}
    ...    target_service=${kubectl}
    ...    context=${CONTEXT}
    ...    search_name=${NAME}
    ...    namespace=${NAMESPACE}
    ...    labels=${LABELS}
    ...    distribution=${DISTRIBUTION}
    ${pod_report}=    RW.K8s.Format Pods Report
    ...    report_data=${rsp}
    ...    search_name=${NAME}
    ...    mute_suggestions=${MUTE_SUGGESTIONS}
    RW.Core.Add Pre To Report    ${pod_report}

Troubleshoot PodDisruptionBudgets
    ${rsp}=    RW.K8s.Check Pdb
    ...    kubeconfig=${KUBECONFIG}
    ...    target_service=${kubectl}
    ...    context=${CONTEXT}
    ...    search_name=${NAME}
    ...    namespace=${NAMESPACE}
    ...    labels=${LABELS}
    ...    distribution=${DISTRIBUTION}
    ${pdb_report}=    RW.K8s.Format Pdb Report
    ...    report_data=${rsp}
    ...    search_name=${NAME}
    ...    mute_suggestions=${MUTE_SUGGESTIONS}
    RW.Core.Add Pre To Report    ${pdb_report}

Troubleshoot Networking
    ${rsp}=    RW.K8s.Check Networking
    ...    kubeconfig=${KUBECONFIG}
    ...    target_service=${kubectl}
    ...    context=${CONTEXT}
    ...    search_name=${NAME}
    ...    namespace=${NAMESPACE}
    ...    labels=${LABELS}
    ...    distribution=${DISTRIBUTION}
    ${networking_report}=    RW.K8s.Format Networking Report
    ...    report_data=${rsp}
    ...    search_name=${NAME}
    ...    mute_suggestions=${MUTE_SUGGESTIONS}
    RW.Core.Add Pre To Report    ${networking_report}
