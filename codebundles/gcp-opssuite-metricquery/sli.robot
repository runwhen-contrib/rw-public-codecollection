*** Settings ***
Documentation     Performs a metric query using a Google MQL statement on the Ops Suite API
...               and pushes the result as an SLI metric.
Library           RW.GCP.OpsSuite
Library           RW.Core
Suite Setup       Suite Initialization

*** Tasks ***
Running GCP OpsSuite Metric Query
    ${metric}=    RW.GCP.OpsSuite.Metric Query
    ...    project_name=${PROJECT_ID}
    ...    mql_statement=${MQL_STATEMENT}
    ...    gcp_credentials=${ops-suite-sa}
    RW.Core.Push Metric    ${metric}

*** Keywords ***
Suite Initialization
    RW.Core.Import Secret    ops-suite-sa
    ...    type=string
    ...    description=GCP service account json used to authenticate with GCP APIs.
    ...    pattern=\w*
    ...    example={"type": "service_account","project_id":"myproject-ID", ... super secret stuff ...}
    RW.Core.Import User Variable    PROJECT_ID
    ...    type=string
    ...    description=The GCP Project ID to scope the API to.
    ...    pattern=\w*
    ...    example=myproject-ID
    RW.Core.Import User Variable    MQL_STATEMENT
    ...    type=string
    ...    description=The MQL statement used to query metrics from the GCP OpsSuite Metric API. Note that a 'within' clause must be present in the query. See https://cloud.google.com/monitoring/mql
    ...    pattern=\w*
    ...    example=fetch kubernetes.io/node/cpu/allocatable_utilization | within 10m | top 1
    Set Suite Variable    ${PROJECT_ID}    ${PROJECT_ID}
    Set Suite Variable    ${MQL_STATEMENT}    ${MQL_STATEMENT}
