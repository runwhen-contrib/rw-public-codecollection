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
    ${double_points}=    RW.GCP.OpsSuite.Remove Units
    ...    data_points=${parsed_points}
    ${avg}=    RW.GCP.OpsSuite.Average Numeric Across Instances    ${double_points}
    Log    OpsSuite result: ${rsp}
    Log    Parsed Points: ${parsed_points}
    Log    Average across selected instances: ${avg}
    RW.Core.Push Metric    ${avg}
