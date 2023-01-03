*** Settings ***
Documentation       Creates an adhoc one-shot job which mounts a PVC as a canary test, which is polled for success before being torn down.
Metadata            Author    Jonathan Funk

Library             BuiltIn
Library             RW.Core
Library             RW.Utils
Library             RW.K8s
Library             RW.platform
Library             OperatingSystem

Suite Setup         Suite Initialization

Force Tags          k8s    kubernetes    kube    canary    PVC    mount    job   


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
    ...    default=Kubernetes
    ${binary_name}=    RW.K8s.Get Binary Name    ${DISTRIBUTION}
    Set Suite Variable    ${binary_name}    ${binary_name}

*** Tasks ***
Run Canary Job
    ${source_dir}=    RW.Utils.Get Source Dir
    ${canary_job_yaml}=    Get File    ${source_dir}/canary_job.yaml
    ${canary_pvc_yaml}=    Get File    ${source_dir}/canary_pvc.yaml
    ${stdout}=    RW.K8s.Shell
    ...    cmd=${binary_name} get job/canary -n ${NAMESPACE} --context ${CONTEXT} -oyaml
    ...    target_service=${kubectl}
    ...    kubeconfig=${kubeconfig}
    # if previous run did not clean up job & pvc fail out of the rest of the suite
    Run Keyword If    """${stdout}""" != ''    RW.Core.Push Metric    0
    Run Keyword If    """${stdout}""" != ''    Fail    Detected leftover job! Please investigate why the previous canary run could not be cleaned up!
    # if canary was cleaned up, proceed
    ${canary_job_yaml}=    RW.Utils.Create Secret    key=canary_job.yaml    val=${canary_job_yaml}
    ${canary_pvc_yaml}=    RW.Utils.Create Secret    key=canary_pvc.yaml    val=${canary_pvc_yaml}
    ${canary_yaml}=    RW.Utils.Create Secrets List    ${canary_job_yaml}    ${canary_pvc_yaml}
    # make the manifests available as secret files on the location service
    ${stdout}=    RW.K8s.Shell
    ...    cmd=cat ./canary_pvc.yaml | ${binary_name} apply -n ${NAMESPACE} --context ${CONTEXT} -f -
    ...    target_service=${kubectl}
    ...    kubeconfig=${kubeconfig}
    ...    shell_secret_files=${canary_yaml}
    ${stdout}=    RW.K8s.Shell
    ...    cmd=cat ./canary_job.yaml | ${binary_name} apply -n ${NAMESPACE} --context ${CONTEXT} -f -
    ...    target_service=${kubectl}
    ...    kubeconfig=${kubeconfig}
    ...    shell_secret_files=${canary_yaml}
    # poll job for success
    ${did_job_succeed}=    RW.K8s.Wait Until Job Successful
    ...    job_name=canary
    ...    namespace=${NAMESPACE}
    ...    context=${CONTEXT}
    ...    kubeconfig=${kubeconfig}
    ...    target_service=${kubectl}
    ...    binary_name=${binary_name}
    ${metric}=    Evaluate    1 if ${did_job_succeed} == True else 0
    # cleanup
    ${stdout}=    RW.K8s.Shell
    ...    cmd=${binary_name} delete job/canary -n ${NAMESPACE} --context ${CONTEXT} && ${binary_name} delete pvc/canary -n ${NAMESPACE} --context ${CONTEXT}
    ...    target_service=${kubectl}
    ...    kubeconfig=${kubeconfig}
    RW.Core.Push Metric    ${metric}

