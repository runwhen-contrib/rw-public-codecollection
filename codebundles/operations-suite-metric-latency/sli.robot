*** Settings ***
Documentation     Check GCP Operations Suite metric latency.
Metadata          Name    operations-suite-metric-latency
Metadata          Type    SLI
Metadata          Author    Vui Le
Force Tags        stackdriver    metric    latency
Library           RW.Core
Library           RW.GCP.OpsSuite
#TODO: Refactor for new platform use

*** Tasks ***
Check Operations Suite Metric Latency For Project
    Import User Variable    SERVICE_DESCR
    Import User Variable    GCP_PROJECT_ID
    Import User Variable    GCP_SERVICE_ACCOUNT_JSON_KEY_VALUES
    Set OpsSuiteCredentials    ${GCP_SERVICE_ACCOUNT_JSON_KEY_VALUES}    verbose=true
    ${res} =    Get Metric Descriptors    ${GCP_PROJECT_ID}
    Push Metric    ${res.latency}    descr=${SERVICE_DESCR}
