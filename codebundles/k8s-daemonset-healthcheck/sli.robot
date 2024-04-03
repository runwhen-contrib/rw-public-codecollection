*** Settings ***
Documentation       Checks that the current state of a daemonset is healthy and returns a score of either 1 (healthy) or 0 (unhealthy).
Metadata            Author    Jonathan Funk
Metadata          Display Name    Kubernetes Daemonset Health Check 
Metadata          Supports    Kubernetes,K8s,AKS,EKS,GKE,OpenShift
Library             BuiltIn
Library             RW.Core
Library             RW.Utils
Library             RW.K8s
Library             RW.platform
Library             OperatingSystem

Suite Setup         Suite Initialization

Force Tags          k8s    kubernetes    kube    namespace    prometheus    health


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
    ${DAEMONSET_NAME}=    RW.Core.Import User Variable    DAEMONSET_NAME
    ...    type=string
    ...    description=The daemonset to health check in the chosen namespace.
    ...    pattern=\w*
    ...    example=vault-csi-provider
    ...    default=vault-csi-provider
    ${NAMESPACE}=    RW.Core.Import User Variable    NAMESPACE
    ...    type=string
    ...    description=The name of the Kubernetes namespace to scope actions and searching to.
    ...    pattern=\w*
    ...    example=vault
    ...    default=vault
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
Health Check Daemonset
    ${stdout}=    RW.K8s.Shell
    ...    cmd=${binary_name} get daemonset/${DAEMONSET_NAME} -n ${NAMESPACE} --context ${CONTEXT} -oyaml
    ...    target_service=${kubectl}
    ...    kubeconfig=${kubeconfig}
    ${daemonset}=    RW.Utils.Yaml To Dict    ${stdout}
    ${healthcheck}=    RW.K8s.Healthcheck Daemonset    daemonset=${daemonset}
    ${metric}=    Evaluate    1 if ${healthcheck} == True else 0
    RW.Core.Push Metric    ${metric}
