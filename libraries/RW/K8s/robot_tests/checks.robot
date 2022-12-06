*** Settings ***
Library           RW.K8s
Library           RW.Utils
Library           RW.platform
Library           RW.Core
Library           OperatingSystem
Suite Setup       Suite Initialization

*** Keywords ***
Suite Initialization
    RW.Core.Import Service    kubectl
    Set Suite Variable    ${kubectl}    ${kubectl}
    Set Suite Variable    ${KUBECONFIG_PATH}    %{KUBECONFIG_PATH}
    Set Suite Variable    ${K8S_TESTING_NS}    %{K8S_TESTING_NS}
    Set Suite Variable    ${K8S_TESTING_CONTEXT}    %{K8S_TESTING_CONTEXT}
    Set Suite Variable    ${K8S_TESTING_NAME}    %{K8S_TESTING_NAME}
    Set Suite Variable    ${K8S_TESTING_LABELS}    %{K8S_TESTING_LABELS}
    ${KUBECONFIG}=    Get File    ${KUBECONFIG_PATH}
    ${KUBECONFIG}=    Evaluate    RW.platform.Secret("kubeconfig", """${KUBECONFIG}""")
    Set Suite Variable    ${KUBECONFIG}    ${KUBECONFIG}

*** Tasks ***
Check Deployment Resources
    ${rsp}=    RW.K8s.Shell
    ...    cmd=kubectl get Deployment/${K8S_TESTING_NAME} --context=${K8S_TESTING_CONTEXT} --namespace=${K8S_TESTING_NS} -o yaml
    ...    target_service=${kubectl}
    ...    kubeconfig=${KUBECONFIG}
    ${deployment}=    RW.Utils.Yaml To Dict    ${rsp}
    ${ret}=    RW.K8s.Check Resources
    ...    deployment=${deployment}
    ...    search_name=${K8S_TESTING_NAME}
    ${resource_report}=    RW.K8s.Format Resources Report
    ...    report_data=${ret}
    ...    search_name=${K8S_TESTING_NAME}
    ...    resource_doc_link=https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/
    ...    mute_suggestions=No
    ${history}=    RW.K8s.Pop Shell History
    ${history}=    RW.Utils.List To String    data_list=${history}    join_with=\n
    Log    ${history}
    Log    ${resource_report}

Check Events
    ${rsp}=    RW.K8s.Shell
    ...    cmd=kubectl get Events --context=${K8S_TESTING_CONTEXT} --namespace=${K8S_TESTING_NS} -o yaml
    ...    target_service=${kubectl}
    ...    kubeconfig=${KUBECONFIG}
    ${events}=    RW.Utils.Yaml To Dict    ${rsp}
    ${rsp}=    RW.K8s.Check Events
    ...    events=${events}
    ...    search_name=${K8S_TESTING_NAME}
    ${events_report}=    RW.K8s.Format Events Report
    ...    report_data=${rsp}
    ...    search_name=${K8S_TESTING_NAME}
    ...    events_doc_link=https://kubernetes.io/docs/reference/kubernetes-api/cluster-resources/event-v1/
    ...    mute_suggestions=No
    ${history}=    RW.K8s.Pop Shell History
    ${history}=    RW.Utils.List To String    data_list=${history}    join_with=\n
    Log    ${history}
    Log    ${events_report}

Check PVC
    ${rsp}=    RW.K8s.Shell
    ...    cmd=kubectl get Deployment --context=${K8S_TESTING_CONTEXT} --namespace=${K8S_TESTING_NS} -o yaml
    ...    target_service=${kubectl}
    ...    kubeconfig=${KUBECONFIG}
    ${deployments}=    RW.Utils.Yaml To Dict    ${rsp}
    ${rsp}=    RW.K8s.Shell
    ...    cmd=kubectl get pvc --context=${K8S_TESTING_CONTEXT} --namespace=${K8S_TESTING_NS} -o yaml
    ...    target_service=${kubectl}
    ...    kubeconfig=${KUBECONFIG}
    ${pvcs}=    RW.Utils.Yaml To Dict    ${rsp}
    ${history}=    RW.K8s.Pop Shell History
    ${history}=    RW.Utils.List To String    data_list=${history}    join_with=\n
    ${rsp}=    RW.K8s.Check PVC
    ...    deployments=${deployments}
    ...    pvcs=${pvcs}
    ${pvc_report}=    RW.K8s.Format PVC Report
    ...    report_data=${rsp}
    ...    mute_suggestions=No
    Log    ${history}
    Log    ${pvc_report}

Check Pods
    ${rsp}=    RW.K8s.Shell
    ...    cmd=kubectl get Pod --selector=${K8S_TESTING_LABELS} --context=${K8S_TESTING_CONTEXT} --namespace=${K8S_TESTING_NS} -o yaml
    ...    target_service=${kubectl}
    ...    kubeconfig=${KUBECONFIG}
    ${pods}=    RW.Utils.Yaml To Dict    ${rsp}
    ${rsp}=    RW.K8s.Check Pods
    ...    pods=${pods}
    ...    search_name=${K8S_TESTING_NAME}
    ${pod_report}=    RW.K8s.Format Pods Report
    ...    report_data=${rsp}
    ${history}=    RW.K8s.Pop Shell History
    ${history}=    RW.Utils.List To String    data_list=${history}    join_with=\n
    Log    ${history}
    Log    ${pod_report}

Check PodDisruptionBudgets
    ${rsp}=    RW.K8s.Shell
    ...    cmd=kubectl get pdb --selector=${K8S_TESTING_LABELS} --context=${K8S_TESTING_CONTEXT} --namespace=${K8S_TESTING_NS} -o yaml
    ...    target_service=${kubectl}
    ...    kubeconfig=${KUBECONFIG}
    ${pdbs}=    RW.Utils.Yaml To Dict    ${rsp}
    ${rsp}=    RW.K8s.Check Pdb
    ...    pdbs=${pdbs}
    ${pdb_report}=    RW.K8s.Format Pdb Report
    ...    report_data=${rsp}
    ...    mute_suggestions=No
    Log    ${pdb_report}
    ${history}=    RW.K8s.Pop Shell History
    ${history}=    RW.Utils.List To String    data_list=${history}    join_with=\n
    Log    ${history}
    # RW.Core.Add To Report    ${resource_report}

Check Networking
    ${rsp}=    RW.K8s.Shell
    ...    cmd=kubectl get Pod --selector=${K8S_TESTING_LABELS} --context=${K8S_TESTING_CONTEXT} --namespace=${K8S_TESTING_NS} -o yaml
    ...    target_service=${kubectl}
    ...    kubeconfig=${KUBECONFIG}
    ${pods}=    RW.Utils.Yaml To Dict    ${rsp}
    ${rsp}=    RW.K8s.Shell
    ...    cmd=kubectl get Service --selector=${K8S_TESTING_LABELS} --context=${K8S_TESTING_CONTEXT} --namespace=${K8S_TESTING_NS} -o yaml
    ...    target_service=${kubectl}
    ...    kubeconfig=${KUBECONFIG}
    ${services}=    RW.Utils.Yaml To Dict    ${rsp}
    ${rsp}=    RW.K8s.Check Networking
    ...    services=${services}
    ...    pods=${pods}
    ${networking_report}=    RW.K8s.Format Networking Report
    ...    report_data=${rsp}
    Log    ${networking_report}

Check Deployment Pods HA
    ${stdout}=    RW.K8s.Shell
    ...    cmd=kubectl get -n ${K8S_TESTING_NS} deployment/crashbandicoot -oyaml
    ...    target_service=${kubectl}
    ...    kubeconfig=${KUBECONFIG}
    ${deployment}=    RW.Utils.Yaml To Dict    ${stdout}
    ${stdout}=    RW.K8s.Shell
    ...    cmd=kubectl get -n ${K8S_TESTING_NS} hpa -oyaml
    ...    target_service=${kubectl}
    ...    kubeconfig=${KUBECONFIG}
    ${hpas}=    RW.Utils.Yaml To Dict    ${stdout}
    ${has_hpa}=    RW.K8s.Has Hpa    hpas=${hpas}    deployment=${deployment}
    ${running_pod_count}=    RW.K8s.Get Available Replicas    ${deployment}
    ${desired_pod_count}=    RW.K8s.Get Desired Replicas    ${deployment}
    ${healthy_state}=    Evaluate    bool(${running_pod_count} == ${desired_pod_count})
    Log    The deployment is healthy (correct number of running replicas): ${healthy_state}
    ${is_ha}=    Evaluate    bool(${running_pod_count} > 1)
    ${remediation_msg}=    RW.Utils.String If Else
    ...    check_boolean=${is_ha}
    ...    if_str=Run to perform rollout: kubectl rollout restart deployment/crashbandicoot -n jon-test
    ...    else_str=The deployment is not highly available, please manually review it to avoid downtime!
    Log    The deployment is Highly Available: ${is_ha}
    Log    Next steps for remediation:\n\t
    Log    ${remediation_msg}
    ${logs}=    RW.K8s.Shell
    ...    cmd=kubectl logs --tail=100 deployment/crashbandicoot -n ${K8S_TESTING_NS}
    ...    target_service=${kubectl}
    ...    kubeconfig=${KUBECONFIG}
    Log    ${logs}

Basic Troubleshoot Namespace
    ${stdout}=    RW.K8s.Shell
    ...    cmd=kubectl get Events --context=${K8S_TESTING_CONTEXT} --namespace=${K8S_TESTING_NS} -o yaml
    ...    target_service=${kubectl}
    ...    kubeconfig=${KUBECONFIG}
    ${events}=    RW.Utils.Yaml To Dict    ${stdout}
    ${event_involved_objects}=    RW.K8s.Get Involved Object Name List    events=${events}
    ${stdout}=    RW.K8s.Shell
    ...    cmd=kubectl get pods --context=${K8S_TESTING_CONTEXT} --namespace=${K8S_TESTING_NS} --field-selector=status.phase==Running -o yaml
    ...    target_service=${kubectl}
    ...    kubeconfig=${KUBECONFIG}
    ${pods}=    RW.Utils.Yaml To Dict    ${stdout}
    ${pod_object_names}=    RW.K8s.Get Object Names    ${pods}
    ${pod_logs}=    RW.K8s.Loop Template Shell
    ...    items=${pod_object_names}
    ...    cmd=kubectl logs --context=${K8S_TESTING_CONTEXT} --namespace=${K8S_TESTING_NS} {item} --tail=100 | grep -E -i "(Error|Exception)"
    ...    target_service=${kubectl}
    ...    kubeconfig=${KUBECONFIG}
    ...    include_empty=True
    ${named_pod_logs}=    RW.Utils.Lists To Dict    keys=${pod_object_names}    values=${pod_logs}
    ${pods_with_error_logs}=    RW.K8s.Get Pod Names With Logs    named_pod_logs=${named_pod_logs}
    ${history}=    RW.K8s.Pop Shell History
    ${history}=    RW.Utils.List To String    data_list=${history}
    Log    ${history}

Full Troubleshoot Namespace
    # mass troubleshoot
    ${stdout}=    RW.K8s.Shell
    ...    cmd=kubectl api-resources --verbs=list --namespaced --context=${K8S_TESTING_CONTEXT} --namespace=${K8S_TESTING_NS} -o name
    ...    target_service=${kubectl}
    ...    kubeconfig=${kubeconfig}
    ${resource_types}=    RW.Utils.Stdout To List    stdout=${stdout}
    ${object_names}=    RW.K8s.Loop Template Shell
    ...    items=${resource_types}
    ...    cmd=kubectl get {item} --no-headers --show-kind --ignore-not-found --context=${K8S_TESTING_CONTEXT} --namespace=${K8S_TESTING_NS} -o name
    ...    target_service=${kubectl}
    ...    kubeconfig=${KUBECONFIG}
    ...    newline_as_separate=True
    ${ts_results}=    RW.K8s.Check Namespace Objects
    ...    k8s_object_names=${object_names}
    ...    context=${K8S_TESTING_CONTEXT}
    ...    namespace=${K8S_TESTING_NS}
    ...    kubeconfig=${KUBECONFIG}
    ...    target_service=${kubectl}
    # check for errors
    ${error_results}=    RW.K8s.Check Namespace Errors
    ...    context=${K8S_TESTING_CONTEXT}
    ...    namespace=${K8S_TESTING_NS}
    ...    kubeconfig=${KUBECONFIG}
    ...    target_service=${kubectl}
    ${history}=    RW.K8s.Pop Shell History
    ${history}=    RW.Utils.List To String    data_list=${history}
    Log    ${history}
    Log    ${error_results}
    Log    ${ts_results}

Help Decomission Objects
    ${stdout}=    RW.K8s.Shell
    ...    cmd=kubectl api-resources --verbs=list --namespaced --context=${K8S_TESTING_CONTEXT} --namespace=${K8S_TESTING_NS} -o name
    ...    target_service=${kubectl}
    ...    kubeconfig=${kubeconfig}
    ${resource_types}=    RW.Utils.Stdout To List    stdout=${stdout}
    ${object_names}=    RW.K8s.Loop Template Shell
    ...    items=${resource_types}
    ...    cmd=kubectl get {item} --no-headers --show-kind --ignore-not-found --context=${K8S_TESTING_CONTEXT} --namespace=${K8S_TESTING_NS} -o name
    ...    target_service=${kubectl}
    ...    kubeconfig=${KUBECONFIG}
    ...    newline_as_separate=True
    ${list_of_k8s_objects}=    RW.K8s.Get Objects By Name
    ...    names=${object_names}
    ...    namespace=${K8S_TESTING_NS}
    ...    context=${K8S_TESTING_CONTEXT}
    ...    target_service=${kubectl}
    ...    kubeconfig=${KUBECONFIG}
    ${found_in_objects}=    RW.K8s.Search Namespace Objects For String
    ...    k8s_items=${list_of_k8s_objects}
    ...    search_string=crashbandic
    ${found_names}=    RW.K8s.Get Object Names    k8s_items=${found_in_objects}
    ${delete_cmds}=    RW.Utils.Templated String List
    ...    template_string=kubectl get {item} --context=${K8S_TESTING_CONTEXT} --namespace=${K8S_TESTING_NS}
    ...    values=${found_names}
    ${command_list}=    RW.Utils.List To String    data_list=${delete_cmds}
    ${history}=    RW.K8s.Pop Shell History
    ${history}=    RW.Utils.List To String    data_list=${history}
