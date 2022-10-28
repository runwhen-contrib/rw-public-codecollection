*** Settings ***
Library           RW.K8s
Library           RW.platform
Library           RW.Core
Library           OperatingSystem
Suite Setup       Suite Initialization

*** Keywords ***
Suite Initialization
    Set Suite Variable    ${KUBECONFIG_PATH}    %{KUBECONFIG_PATH}
    Set Suite Variable    ${K8S_TESTING_NS}    %{K8S_TESTING_NS}
    Set Suite Variable    ${K8S_TESTING_CONTEXT}    %{K8S_TESTING_CONTEXT}
    Set Suite Variable    ${K8S_TESTING_NAME}    %{K8S_TESTING_NAME}
    Set Suite Variable    ${K8S_TESTING_LABELS}    %{K8S_TESTING_LABELS}
    ${KUBECONFIG}=    Get File    ${KUBECONFIG_PATH}
    ${KUBECONFIG}=    Evaluate    RW.platform.Secret("kubeconfig", """${KUBECONFIG}""")
    Set Suite Variable    ${KUBECONFIG}    ${KUBECONFIG}

*** Tasks ***
Check Deployment Resources With Labels
    ${rsp}=    RW.K8s.Check Resources
    ...    kubeconfig=${KUBECONFIG}
    ...    context=${K8S_TESTING_CONTEXT}
    ...    namespace=${K8S_TESTING_NS}
    ...    search_name=${K8S_TESTING_NAME}
    ...    labels=${K8S_TESTING_LABELS}
    ${resource_report}=    RW.K8s.Format Resources Report
    ...    report_data=${rsp}
    ...    search_name=${K8S_TESTING_NAME}
    ...    resource_doc_link=https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/
    ...    mute_suggestions=No
    Log    ${resource_report}
    # RW.Core.Add To Report    ${resource_report}

Check Events
    ${rsp}=    RW.K8s.Check Events
    ...    kubeconfig=${KUBECONFIG}
    ...    context=${K8S_TESTING_CONTEXT}
    ...    namespace=${K8S_TESTING_NS}
    ...    search_name=${K8S_TESTING_NAME}
    ${events_report}=    RW.K8s.Format Events Report
    ...    report_data=${rsp}
    ...    search_name=${K8S_TESTING_NAME}
    ...    events_doc_link=https://kubernetes.io/docs/reference/kubernetes-api/cluster-resources/event-v1/
    ...    mute_suggestions=No
    Log    ${events_report}
    # RW.Core.Add To Report    ${resource_report}

Check PVC
    ${rsp}=    RW.K8s.Check PVC
    ...    kubeconfig=${KUBECONFIG}
    ...    context=${K8S_TESTING_CONTEXT}
    ...    namespace=${K8S_TESTING_NS}
    ...    search_name=${K8S_TESTING_NAME}
    ${events_report}=    RW.K8s.Format PVC Report
    ...    report_data=${rsp}
    ...    search_name=${K8S_TESTING_NAME}
    ...    mute_suggestions=No
    Log    ${events_report}
    # RW.Core.Add To Report    ${resource_report}

Check Pods
    ${rsp}=    RW.K8s.Check Pods
    ...    kubeconfig=${KUBECONFIG}
    ...    context=${K8S_TESTING_CONTEXT}
    ...    search_name=${K8S_TESTING_NAME}
    ...    namespace=${K8S_TESTING_NS}
    ...    labels=${K8S_TESTING_LABELS}
    ${pod_report}=    RW.K8s.Format Pods Report
    ...    report_data=${rsp}
    ...    search_name=${K8S_TESTING_NAME}
    ...    mute_suggestions=No
    Log    ${pod_report}

Check PodDisruptionBudgets
    ${rsp}=    RW.K8s.Check Pdb
    ...    kubeconfig=${KUBECONFIG}
    ...    context=${K8S_TESTING_CONTEXT}
    ...    search_name=${K8S_TESTING_NAME}
    ...    namespace=${K8S_TESTING_NS}
    ...    labels=${K8S_TESTING_LABELS}
    ${pdb_report}=    RW.K8s.Format Pdb Report
    ...    report_data=${rsp}
    ...    search_name=${K8S_TESTING_NAME}
    ...    mute_suggestions=No
    Log    ${pdb_report}
    # RW.Core.Add To Report    ${resource_report}

Check Networking
    ${rsp}=    RW.K8s.Check Networking
    ...    kubeconfig=${KUBECONFIG}
    ...    context=${K8S_TESTING_CONTEXT}
    ...    search_name=${K8S_TESTING_NAME}
    ...    namespace=${K8S_TESTING_NS}
    ...    labels=${K8S_TESTING_LABELS}
    ${networking_report}=    RW.K8s.Format Networking Report
    ...    report_data=${rsp}
    ...    search_name=${K8S_TESTING_NAME}
    ...    mute_suggestions=No
    Log    ${networking_report}
