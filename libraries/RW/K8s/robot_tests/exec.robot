*** Settings ***
Library           RW.K8s
Library           RW.Postgres
Library           RW.Utils
Library           RW.platform
Library           RW.Core
Library           OperatingSystem
Suite Setup       Suite Initialization

*** Tasks ***
Get Postgres Query Result
    ${templated_query}=    RW.Postgres.Template Command
    ...    query=${K8S_DB_QUERY}
    ...    hostname=localhost
    ...    database=${TEST_DB}
    ...    username=${TEST_USER}
    ...    password=${TEST_DB_PASSWORD}
    ${shell_secrets}=    RW.Utils.Secrets List    ${TEST_DB}    ${TEST_USER}    ${TEST_DB_PASSWORD}
    ${rsp}=    RW.K8s.Shell
    ...    cmd=kubectl exec ${TEST_DB_WORKLOAD} -- bash -c "${templated_query}"
    ...    target_service=${kubectl}
    ...    kubeconfig=${KUBECONFIG}
    ...    shell_secrets=${shell_secrets}

*** Keywords ***
Suite Initialization
    RW.Core.Import Service    kubectl
    Set Suite Variable    ${kubectl}    ${kubectl}
    Set Suite Variable    ${KUBECONFIG_PATH}    %{KUBECONFIG_PATH}
    Set Suite Variable    ${TEST_DB_WORKLOAD}    %{TEST_DB_WORKLOAD}
    Set Suite Variable    ${K8S_DB_QUERY}    %{K8S_DB_QUERY}
    ${KUBECONFIG}=    Get File    ${KUBECONFIG_PATH}
    ${KUBECONFIG}=    Evaluate    RW.platform.Secret("kubeconfig", """${KUBECONFIG}""")
    ${TEST_DB}=    Evaluate    RW.platform.Secret("test_db", """%{TEST_DB}""")
    ${TEST_USER}=    Evaluate    RW.platform.Secret("test_user", """%{TEST_DB_USER}""")
    ${TEST_DB_PASSWORD}=    Evaluate    RW.platform.Secret("test_pass", """%{TEST_DB_PASSWORD}""")
    Set Suite Variable    ${KUBECONFIG}    ${KUBECONFIG}
    Set Suite Variable    ${TEST_DB}    ${TEST_DB}
    Set Suite Variable    ${TEST_USER}    ${TEST_USER}
    Set Suite Variable    ${TEST_DB_PASSWORD}    ${TEST_DB_PASSWORD}
