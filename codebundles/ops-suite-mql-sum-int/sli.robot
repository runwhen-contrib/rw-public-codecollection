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
    ${sum}=    RW.GCP.OpsSuite.Sum Numeric Across Instances
    ...    data_points=${parsed_points}
    ...    point_type=int64_value
    Log    OpsSuite result: ${rsp}
    Log    Parsed Points: ${parsed_points}
    Log    Sum across selected instances: ${sum}
    RW.Core.Push Metric    ${sum}
