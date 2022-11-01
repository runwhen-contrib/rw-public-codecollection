*** Settings ***
Documentation     Retrieve the count of all AWS accounts in an organization.
Metadata          Name    aws-account-limit
Metadata          Type    SLI
Metadata          Author    Vui Le
Force Tags        aws    accounts    limit
Library           RW.Core
Library           RW.AWS
#TODO: Refactor for new platform use

*** Tasks ***
Get Count Of AWS Accounts In Organization
    Import User Variable    SERVICE_DESCR
    Import User Variable    AWS_ACCESS_KEY_ID
    Import User Variable    AWS_SECRET_ACCESS_KEY
    Import User Variable    REGION_NAME
    Set Credentials    ${AWS_ACCESS_KEY_ID}    ${AWS_SECRET_ACCESS_KEY}    ${REGION_NAME}
    ${res} =    Get Accounts    verbose=True
    Push Metric    ${res.count}    descr=${SERVICE_DESCR}
    ...    status_code=${res.status_code}
    ...    ok=${res.ok}
    ...    ok_status=${res.ok_status}
