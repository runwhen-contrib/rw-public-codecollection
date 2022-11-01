*** Settings ***
Metadata          Author    Jonathan Funk
Documentation     Retreieve aggregate data via kubectl top command.
Force Tags        K8s    Kubernetes    Kube    K8    Kubectl
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
    ${KUBECTL_COMMAND}=    RW.Core.Import User Variable    KUBECTL_COMMAND
    ...    type=string
    ...    description=The kubectl top command to fetch stdout data with.
    ...    pattern=\w*
    ...    example=kubectl --context my-context -n my-namespace top pods
    ${DATA_COLUMN}=    RW.Core.Import User Variable    DATA_COLUMN
    ...    type=string
    ...    description=Which kubectl zero-relative stdout column to use for aggregating data. Note that column 0 typically contains the name.
    ...    pattern="^[0-9]*$"
    ...    default=1
    ...    example=1
    ${AGGREGATION}=    RW.Core.Import User Variable    AGGREGATION
    ...    type=string
    ...    enum=[Max,Average,Minimum,Sum]
    ...    description=What aggregation method to apply to the column data.
    ...    default=Max
    ...    example=Max
    ${DISTRIBUTION}=    RW.Core.Import User Variable    DISTRIBUTION
    ...    type=string
    ...    description=Which distribution of Kubernetes to use for operations, such as: Kubernetes, OpenShift, etc.
    ...    pattern=\w*
    ...    enum=[Kubernetes,GKE,OpenShift]
    ...    example=Kubernetes

*** Tasks ***
Running Kubectl Top And Extracting Metric Data
    ${rsp}=    RW.K8s.Kubectl    ${KUBECTL_COMMAND}
    ...    target_service=${kubectl}
    ...    kubeconfig=${kubeconfig}
    ${stdout}=    Set Variable    ${rsp.stdout}
    ${datagrid}=    RW.K8s.Stdout To Grid    ${stdout}
    ${column}=    RW.K8s.Get Stdout Grid Column    ${datagrid}    ${DATA_COLUMN}
    ${cleaned_column}=    RW.K8s.Remove Units    ${column}
    ${metric}=    RW.K8s.Top Aggregate    ${AGGREGATION}    ${cleaned_column}
    RW.Core.Push Metric    ${metric}
