*** Settings ***
Documentation       Runs multiple Kubernetes and psql commands to report on the health of a postgres cluster. 
Metadata            Author    Shea Stewart

Library             RW.Core
Library             RW.K8s
Library             RW.Postgres
Library             RW.Utils
Library             RW.platform

Suite Setup         Suite Initialization

Force Tags          k8s    kubernetes    postgres    sql    database    psql    triage


*** Tasks ***
Get Standard Resources  
    ${stdout}=    RW.K8s.Shell
    ...    cmd=kubectl get all -l ${RESOURCE_LABELS} -n ${NAMESPACE} --context ${CONTEXT}
    ...    target_service=${kubectl}
    ...    kubeconfig=${KUBECONFIG}
    ${history}=    RW.K8s.Pop Shell History
    ${history}=    RW.Utils.List To String    data_list=${history}
    RW.Core.Add Pre To Report    ${stdout}
    RW.Core.Add Pre To Report    Commands Used: ${history}

Describe Custom Resources  
    ${custom_resource_list}=    RW.K8s.Get Custom Resources
    ...    target_service=${kubectl}
    ...    kubeconfig=${KUBECONFIG}
    ...    context=${CONTEXT}
    ...    namespace=${NAMESPACE}
    ...    crd_filter="${CRD_FILTER}"
        
    ${custom_resource_details}=     RW.K8s.Describe Custom Resources
    ...    target_service=${kubectl}
    ...    kubeconfig=${KUBECONFIG}
    ...    context=${CONTEXT}
    ...    namespace=${NAMESPACE}
    ...    custom_resources=${custom_resource_list}
    ${history}=    RW.K8s.Pop Shell History
    ${history}=    RW.Utils.List To String    data_list=${history}
    RW.Core.Add Pre To Report    ${custom_resource_details}
    RW.Core.Add Pre To Report    Commands Used: ${history} 

Get Pod Logs & Events
    ${pod_logs}=     RW.K8s.Fetch Pod Logs and Events By Label
    ...    target_service=${kubectl}
    ...    kubeconfig=${KUBECONFIG}
    ...    context=${CONTEXT}
    ...    namespace=${NAMESPACE}
    ...    resource_labels=${RESOURCE_LABELS}
    ...    log_lines=${LOG_LINES}
    ${history}=    RW.K8s.Pop Shell History
    ${history}=    RW.Utils.List To String    data_list=${history}
    RW.Core.Add Pre To Report    ${pod_logs}
    RW.Core.Add Pre To Report    Commands Used: ${history}

Get Pod Resource Utilization
    ${pod_resource_utilization}=     RW.K8s.Fetch Pod Resource Utilization By Label
    ...    target_service=${kubectl}
    ...    kubeconfig=${KUBECONFIG}
    ...    context=${CONTEXT}
    ...    namespace=${NAMESPACE}
    ...    resource_labels=${RESOURCE_LABELS}
    ${history}=    RW.K8s.Pop Shell History
    ${history}=    RW.Utils.List To String    data_list=${history}
    RW.Core.Add Pre To Report    ${pod_resource_utilization}
    RW.Core.Add Pre To Report    Commands Used: ${history}

# Get Running Configuration


# Get DB Statistics



# Run Postgres Query And Results to Report
#     ${templated_query}=    RW.Postgres.Template Command
#     ...    query=${QUERY}
#     ...    hostname=${HOSTNAME}
#     ...    database=${psql_database}
#     ...    username=${psql_username}
#     ...    password=${psql_password}
#     ...    report=True
#     ${shell_secrets}=    RW.Utils.Create Secrets List    ${psql_database}    ${psql_username}    ${psql_password}
#     ${workload}=    RW.K8s.Template Workload
#     ...    workload_name=${WORKLOAD_NAME}
#     ...    workload_namespace=${WORKLOAD_NAMESPACE}
#     ...    workload_container=${WORKLOAD_CONTAINER}
#     ${rsp}=    RW.K8s.Shell
#     ...    cmd=${binary_name} exec ${workload} -- bash -c "${templated_query}" --context ${CONTEXT}
#     ...    target_service=${kubectl}
#     ...    kubeconfig=${KUBECONFIG}
#     ...    shell_secrets=${shell_secrets}
#     RW.Core.Add Pre To Report    ${rsp}


*** Keywords ***
Suite Initialization
    ${kubeconfig}=    RW.Core.Import Secret
    ...    kubeconfig
    ...    type=string
    ...    description=The kubernetes kubeconfig yaml containing connection configuration used to connect to cluster(s).
    ...    pattern=\w*
    ...    example=For examples, start here https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/
    ${psql_password}=    RW.Core.Import Secret    psql_password
    ...    type=string
    ...    description=The password used when querying the postgres database.
    ...    pattern=\w*
    ...    example=mysupersecretpassword
    ${psql_database}=    RW.Core.Import Secret    psql_database
    ...    type=string
    ...    description=The database name used to determine what database is being queried.
    ...    pattern=\w*
    ...    example=mydb
    ${psql_username}=    RW.Core.Import Secret    psql_username
    ...    type=string
    ...    description=The username used when querying the postgres database.
    ...    pattern=\w*
    ...    example=myuser
    ${kubectl}=    RW.Core.Import Service    kubectl
    ...    description=The location service used to interpret shell commands.
    ...    default=kubectl-service.shared
    ...    example=kubectl-service.shared
    ${CONTEXT}=    RW.Core.Import User Variable    CONTEXT
    ...    type=string
    ...    description=Which Kubernetes context to operate within.
    ...    pattern=\w*
    ...    example=my-main-cluster
   ${INCLUDE_CUSTOM_RESOURCES}=    RW.Core.Import User Variable
    ...    INCLUDE_CUSTOM_RESOURCES
    ...    type=string
    ...    pattern=\w*
    ...    enum=[Yes,No]
    ...    description=Include details from custom resources. Requires SA to have access to list custom resources in the API group apiextensions.k8s.io Typically applies to operator based deployments. 
    ...    default='No'
   ${CRD_FILTER}=    RW.Core.Import User Variable
    ...    CRD_FILTER
    ...    type=string
    ...    pattern=\w*
    ...    description=Custom resource filter to identify any custom types. Typically applies to operator based deployments. 
    ...    example=postgresclusters.postgres-operator.crunchydata.com
    ...    default=postgres
   ${RESOURCE_LABELS}=    RW.Core.Import User Variable
    ...    RESOURCE_LABELS
    ...    type=string
    ...    description=Labels that can be used to identify all resources associated with the database. 
    ...    example=postgres-operator.crunchydata.com/cluster=main-db
    ${LOG_LINES}=    RW.Core.Import User Variable
    ...    LOG_LINES
    ...    type=string
    ...    description=How many logs to fetch. -1 fetches all logs. 
    ...    example=100 
    ...    default=100    
    ${WORKLOAD_NAME}=    RW.Core.Import User Variable
    ...    WORKLOAD_NAME
    ...    type=string
    ...    description=Which workload to run the postgres query from. This workload should have the psql binary in its image and be able to access the database workload within its network constraints. Accepts namespace and container details if desired.
    ...    pattern=\w*
    ...    example=deployment/myapp
    ${WORKLOAD_LABELS}=    RW.Core.Import User Variable
    ...    WORKLOAD_LABELS
    ...    type=string
    ...    description=Which labels identify workload to run the query from. This workload should have the psql binary in its image and be able to access the database workload within its network constraints. Accepts namespace and container details if desired.
    ...    pattern=\w*
    ...    example=postgres-operator.crunchydata.com/role=primary,postgres-operator.crunchydata.com/cluster=main-db
    ${NAMESPACE}=    RW.Core.Import User Variable
    ...    NAMESPACE
    ...    type=string
    ...    description=Which namespace the workload is in.
    ...    example=my-database-namespace
    ${WORKLOAD_CONTAINER}=    RW.Core.Import User Variable
    ...    WORKLOAD_CONTAINER
    ...    type=string
    ...    description=Which container contains the psql binary. Not all pods will default to the correct container - set this to specify the container name.
    ...    example=database
    ${QUERY}=    RW.Core.Import User Variable
    ...    QUERY
    ...    type=string
    ...    description=The postgres query to run on the workload. Ensure this query returns a single row with a numerical value.
    ...    pattern=\w*
    ...    default=SELECT 1;
    ...    example=SELECT COUNT(id) FROM my_table;
    ${HOSTNAME}=    RW.Core.Import User Variable
    ...    HOSTNAME
    ...    type=string
    ...    description=The hostname specified in the psql connection string. Use localhost, or leave blank, if the execution workload is also hosting the database.
    ...    pattern=\w*
    ...    example=localhost
    ${DISTRIBUTION}=    RW.Core.Import User Variable    DISTRIBUTION
    ...    type=string
    ...    description=Which distribution of Kubernetes to use for operations, such as: Kubernetes, OpenShift, etc.
    ...    pattern=\w*
    ...    enum=[Kubernetes,GKE,OpenShift]
    ...    example=Kubernetes
    ${binary_name}=    RW.K8s.Get Binary Name    ${DISTRIBUTION}
    Set Suite Variable    ${binary_name}    ${binary_name}
    Set Suite Variable    ${kubeconfig}    ${kubeconfig}
