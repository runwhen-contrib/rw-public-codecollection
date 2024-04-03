*** Settings ***
Documentation     Retrieve all recently created AWS accounts.
Metadata          Name    aws-account-limit
Metadata          Display Name    AWS Account Creation Notification
Metadata          Type    Runbook
Metadata          Author    Vui Le
Metadata          Supports    aws,iam
Force Tags        aws    accounts
Suite Setup       Runbook Setup
Suite Teardown    Runbook Teardown
Library           RW.Core
Library           RW.AWS
Library           RW.Slack
Library           RW.Report
#TODO: Refactor for new platform use

*** Tasks ***
Get The Recently Created AWS Accounts
    ${res} =    Get Recently Created Accounts    verbose=true
    Add To Report    *Accounts*
    Add To Report    ${res.accounts}    # fields=Name Id Email Arn Status JoinedDatetime OrganizationUnitFullName

*** Keywords ***
Runbook Setup
    Import User Variable    SERVICE_DESCR
    Import User Variable    AWS_ACCESS_KEY_ID
    Import User Variable    AWS_SECRET_ACCESS_KEY
    Import User Variable    REGION_NAME
    Import User Variable    SLACK_CHANNEL
    Import User Variable    SLACK_BOT_TOKEN
    Set Credentials    ${AWS_ACCESS_KEY_ID}    ${AWS_SECRET_ACCESS_KEY}    ${REGION_NAME}

Runbook Teardown
    ${report} =    Get Report
    RW.Slack.Post Message
    ...    token=${SLACK_BOT_TOKEN}
    ...    channel=${SLACK_CHANNEL}
    ...    flag=red
    ...    title=${SERVICE_DESCR} Troubleshooting Report
    ...    msg=${report}
