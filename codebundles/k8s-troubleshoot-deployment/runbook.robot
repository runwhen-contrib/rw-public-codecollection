*** Settings ***
Metadata          Author    Jonathan Funk
Documentation     A taskset for troubleshooting general issues associated with typical kubernetes deployment resources.
...               Supports API interactions via both the API client and Kubectl binary through RunWhen Shell Services.
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
    ${binary_name}=    RW.K8s.Get Binary Name    ${DISTRIBUTION}
    Set Suite Variable    ${binary_name}    ${binary_name}

*** Tasks ***
Troubleshoot Resourcing
    ${stdout}=    RW.K8s.Shell
    ...    cmd=${binary_name} get Deployment --selector=${LABELS} --no-headers -o custom-columns=":metadata.name" --context ${CONTEXT} -n ${NAMESPACE} | grep "${NAME}" | xargs -I '{deploy_name}' ${binary_name} get Deployment/{deploy_name} --context=${CONTEXT} --namespace=${NAMESPACE} -o yaml
    ...    target_service=${kubectl}
    ...    kubeconfig=${KUBECONFIG}
    ${deployment}=    RW.Utils.Yaml To Dict    ${stdout}
    ${ret}=    RW.K8s.Check Resources
    ...    deployment=${deployment}
    ...    search_name=${NAME}
    ${resource_report}=    RW.K8s.Format Resources Report
    ...    report_data=${ret}
    ...    search_name=${NAME}
    ...    resource_doc_link=https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/
    ...    mute_suggestions=${MUTE_SUGGESTIONS}
    ${history}=    RW.K8s.Pop Shell History
    ${history}=    RW.Utils.List To String    data_list=${history}
    RW.Core.Add Pre To Report    Commands Used: ${history}
    RW.Core.Add Pre To Report    ${resource_report}

Troubleshoot Events
    ${stdout}=    RW.K8s.Shell
    ...    cmd=${binary_name} get Events --context=${CONTEXT} --namespace=${NAMESPACE} -o yaml
    ...    target_service=${kubectl}
    ...    kubeconfig=${KUBECONFIG}
    ${events}=    RW.Utils.Yaml To Dict    ${stdout}
    ${rsp}=    RW.K8s.Check Events
    ...    events=${events}
    ...    search_name=${NAME}
    ${events_report}=    RW.K8s.Format Events Report
    ...    report_data=${rsp}
    ...    search_name=${NAME}
    ...    events_doc_link=https://kubernetes.io/docs/reference/kubernetes-api/cluster-resources/event-v1/
    ...    mute_suggestions=${MUTE_SUGGESTIONS}
    ${history}=    RW.K8s.Pop Shell History
    ${history}=    RW.Utils.List To String    data_list=${history}
    RW.Core.Add Pre To Report    Commands Used: ${history}
    RW.Core.Add Pre To Report    ${events_report}

Troubleshoot PVC
    ${stdout}=    RW.K8s.Shell
    ...    cmd=${binary_name} get pvc --context=${CONTEXT} --namespace=${NAMESPACE} -o yaml
    ...    target_service=${kubectl}
    ...    kubeconfig=${KUBECONFIG}
    ${pvcs}=    RW.Utils.Yaml To Dict    ${stdout}
    ${stdout}=    RW.K8s.Shell
    ...    cmd=${binary_name} get deployment --context=${CONTEXT} --namespace=${NAMESPACE} -o yaml
    ...    target_service=${kubectl}
    ...    kubeconfig=${KUBECONFIG}
    ${deployments}=    RW.Utils.Yaml To Dict    ${stdout}
    ${rsp}=    RW.K8s.Check PVC
    ...    deployments=${deployments}
    ...    pvcs=${pvcs}
    ${pvc_report}=    RW.K8s.Format PVC Report
    ...    report_data=${rsp}
    ...    mute_suggestions=${MUTE_SUGGESTIONS}
    ${history}=    RW.K8s.Pop Shell History
    ${history}=    RW.Utils.List To String    data_list=${history}
    RW.Core.Add Pre To Report    Commands Used: ${history}
    RW.Core.Add Pre To Report    ${pvc_report}

Troubleshoot Pods
    ${stdout}=    RW.K8s.Shell
    ...    cmd=${binary_name} get Pods --context=${CONTEXT} --namespace=${NAMESPACE} -o yaml
    ...    target_service=${kubectl}
    ...    kubeconfig=${KUBECONFIG}
    ${pods}=    RW.Utils.Yaml To Dict    ${stdout}
    ${rsp}=    RW.K8s.Check Pods
    ...    pods=${pods}
    ...    search_name=${NAME}
    ${pod_report}=    RW.K8s.Format Pods Report
    ...    report_data=${rsp}
    ${history}=    RW.K8s.Pop Shell History
    ${history}=    RW.Utils.List To String    data_list=${history}
    RW.Core.Add Pre To Report    Commands Used: ${history}
    RW.Core.Add Pre To Report    ${pod_report}

Troubleshoot PodDisruptionBudgets
    ${stdout}=    RW.K8s.Shell
    ...    cmd=${binary_name} get pdb --context=${CONTEXT} --namespace=${NAMESPACE} -o yaml
    ...    target_service=${kubectl}
    ...    kubeconfig=${KUBECONFIG}
    ${pdbs}=    RW.Utils.Yaml To Dict    ${stdout}
    ${rsp}=    RW.K8s.Check Pdb    pdbs=${pdbs}
    ${pdb_report}=    RW.K8s.Format Pdb Report
    ...    report_data=${rsp}
    ...    mute_suggestions=${MUTE_SUGGESTIONS}
    ${history}=    RW.K8s.Pop Shell History
    ${history}=    RW.Utils.List To String    data_list=${history}
    RW.Core.Add Pre To Report    Commands Used: ${history}
    RW.Core.Add Pre To Report    ${pdb_report}

Troubleshoot Networking
    ${rsp}=    RW.K8s.Shell
    ...    cmd=${binary_name} get Pod --context=${CONTEXT} --namespace=${NAMESPACE} -o yaml
    ...    target_service=${kubectl}
    ...    kubeconfig=${KUBECONFIG}
    ${pods}=    RW.Utils.Yaml To Dict    ${rsp}
    ${rsp}=    RW.K8s.Shell
    ...    cmd=${binary_name} get Service --context=${CONTEXT} --namespace=${NAMESPACE} -o yaml
    ...    target_service=${kubectl}
    ...    kubeconfig=${KUBECONFIG}
    ${services}=    RW.Utils.Yaml To Dict    ${rsp}
    ${rsp}=    RW.K8s.Check Networking
    ...    services=${services}
    ...    pods=${pods}
    ${networking_report}=    RW.K8s.Format Networking Report
    ...    report_data=${rsp}
    ...    mute_suggestions=${MUTE_SUGGESTIONS}
    ${history}=    RW.K8s.Pop Shell History
    ${history}=    RW.Utils.List To String    data_list=${history}
    RW.Core.Add Pre To Report    Commands Used: ${history}
    RW.Core.Add Pre To Report    ${networking_report}
