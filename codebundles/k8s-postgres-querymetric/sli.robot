*** Settings ***
Metadata          Author    Jonathan Funk
Documentation     Runs a postgres SQL query and pushes the returned query result as an SLI metric.
...               During execution, the SQL query should be passed to a Kubernetes workload that has access to the psql binary.
...               The workload will run the query and return the result from stdout.
Force Tags        K8s    Kubernetes    Postgres    SQL    database    psql
Suite Setup       Suite Initialization
Library           RW.Core
Library           RW.K8s
Library           RW.Postgres
Library           RW.Utils
Library           RW.platform

*** Keywords ***
Suite Initialization
    ${kubeconfig}=    RW.Core.Import Secret    kubeconfig
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
    ${WORKLOAD_NAME}=    RW.Core.Import User Variable    WORKLOAD_NAME
    ...    type=string
    ...    description=Which workload to run the postgres query from. This workload should have the psql binary in its image and be able to access the database workload within its network constraints.
    ...    pattern=\w*
    ...    example=deployment/myapp
    ${QUERY}=    RW.Core.Import User Variable    QUERY
    ...    type=string
    ...    description=The postgres query to run on the workload. Ensure this query returns a single row with a numerical value.
    ...    pattern=\w*
    ...    default=SELECT 1;
    ...    example=SELECT COUNT(id) FROM my_table;
    ${HOSTNAME}=    RW.Core.Import User Variable    HOSTNAME
    ...    type=string
    ...    description=The hostname specified in the psql connection string. Use localhost if the execution workload is the database workload.
    ...    pattern=\w*
    ...    default=localhost
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

*** Tasks ***
Run Postgres Query And Return Result As Metric
    ${templated_query}=    RW.Postgres.Template Command
    ...    query=${QUERY}
    ...    hostname=${HOSTNAME}
    ...    database=${psql_database}
    ...    username=${psql_username}
    ...    password=${psql_password}
    ${shell_secrets}=    RW.Utils.Create Secrets List    ${psql_database}    ${psql_username}    ${psql_password}
    ${rsp}=    RW.K8s.Shell
    ...    cmd=${binary_name} exec ${WORKLOAD_NAME} -- bash -c "${templated_query}"
    ...    target_service=${kubectl}
    ...    kubeconfig=${KUBECONFIG}
    ...    shell_secrets=${shell_secrets}
    ${metric}=    RW.Utils.To Float    ${rsp}
    RW.Core.Push Metric    ${metric}
