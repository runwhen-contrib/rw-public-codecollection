*** Settings ***
Documentation     Retrieve the result of an MQL query against the GCP Monitoring API.
Library           RW.GCP.OpsSuite
Library           RW.Core
Suite Setup       Suite Initialization

*** Tasks ***
Running GCP OpsSuite Metric Query
    RW.GCP.OpsSuite.Authenticate    ${OPS_SUITE_SA}
    ${metric}=    RW.GCP.OpsSuite.Metric Query    ${PROJECT_ID}    ${MQL_STATEMENT}
    RW.Core.Push Metric    ${metric}

*** Keywords ***
Suite Initialization
    ${secret}=    Import Secret    ops-suite-sa
    ${OPS_SUITE_SA}=    Set Variable    ${secret.value}
    RW.Core.Import User Variable    PROJECT_ID
    RW.Core.Import User Variable    MQL_STATEMENT
    Set Suite Variable    ${OPS_SUITE_SA}    ${OPS_SUITE_SA}
    Set Suite Variable    ${PROJECT_ID}    ${PROJECT_ID}
    Set Suite Variable    ${MQL_STATEMENT}    ${MQL_STATEMENT}
