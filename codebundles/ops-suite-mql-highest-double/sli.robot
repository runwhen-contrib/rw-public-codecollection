*** Settings ***
Documentation     DEPRECATED
Library           RW.Core
Library           RW.GCP.OpsSuite

*** Tasks ***
Running OpsSuite Client Metric Query
    Log    Importing secrets...
    ${secret}=    Import Secret    opsuite-sa
    ${opssuite_sa_creds}=    Set Variable    ${secret.value}
    Log    Importing config variables...
    RW.Core.Import User Variable    PROJECT_ID
    RW.Core.Import User Variable    MQL_STATEMENT
    Log    Executing client query
    RW.GCP.OpsSuite.Authenticate    ${opssuite_sa_creds}
    ${rsp}=    RW.GCP.OpsSuite.Run Mql    ${PROJECT_ID}    ${MQL_STATEMENT}
    ${parsed_points}=    RW.GCP.OpsSuite.Get Last Point In Series Set    ${rsp}
    ${highest}=    RW.GCP.OpsSuite.Highest Numeric Across Instances    ${parsed_points}
    Log    OpsSuite result: ${rsp}
    Log    Parsed Points: ${parsed_points}
    Log    Highest across selected instances: ${highest}
    RW.Core.Push Metric    ${highest}
