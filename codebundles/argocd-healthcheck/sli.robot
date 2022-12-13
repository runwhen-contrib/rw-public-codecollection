*** Settings ***
Metadata          Author    Paul Dittaro
Documentation     Check the health of ArgoCD platfrom by checking the availability of its underlying Deployments and StatefulSets.
Force Tags        K8s    Kubernetes    Kube    K8    Kubectl    argocd
Suite Setup       Suite Initialization
Library           BuiltIn
Library           RW.Core
Library           RW.K8s

*** Keywords ***
Suite Initialization
    ${kubeconfig}=    RW.Core.Import Secret    kubeconfig
    ${kubectl}=    RW.Core.Import Service    kubectl
    ${NAMESPACE}=    RW.Core.Import User Variable    NAMESPACE
    ...    type=string
    ...    description=The Kubernetes namespace your ArgoCD install resides in.
    ...    pattern=\w*
    ...    example=argocd
    ...    default=argocd
    ${CONTEXT}=    RW.Core.Import User Variable    CONTEXT
    ...    type=string
    ...    description=Which Kubernetes context to operate within.
    ...    pattern=\w*
    ...    example=my-main-cluster

*** Tasks ***
ArgoCD Health Check
    ${health}=    True

    @(deployments)=    argocd-applicationset-controller
    ...                argocd-dex-server
    ...                argocd-notifications-controller
    ...                argocd-redis
    ...                argocd-repo-server
    ...                argocd-server

    @(statefulsets)=    argocd-application-controller
    
    FOR ${deployment} in @(deployments)
        ${rsp}=    RW.K8s.Shell
        ...    cmd=kubectl get deployment.apps/${deployment} --context=${CONTEXT} --namespace=${NAMESPACE} -o jsonpath='{.status.conditions[?(@.type=="Available")].status}'
        ...    target_service=${kubectl}
        ...    kubeconfig=${KUBECONFIG}
        ${health}=    Evaluate    ${health} if ${rsp} == "True" else False
    END

    FOR ${statefulset} in @(statefulsets)
        ${rsp}=    RW.K8s.Shell
        ...    cmd=kubectl get statefulset.apps/${statefulset} --context=${CONTEXT} --namespace=${NAMESPACE} -o jsonpath='{.status.availableReplicas}'
        ...    target_service=${kubectl}
        ...    kubeconfig=${KUBECONFIG}
        ${health}=    Evaluate    ${health} if ${rsp} > 0 else False
    END

    ${metric}=    Evaluate    1 if ${health} is True else 0
    RW.Core.Push Metric    ${metric}
