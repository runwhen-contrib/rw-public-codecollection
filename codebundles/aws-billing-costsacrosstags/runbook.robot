*** Settings ***
Metadata          Author    Jonathan Funk
Documentation     Creates a report of AWS line item costs filtered to a list of tagged resources
Force Tags        AWS    Cost    Billing    CostExplorer    Usage    Report
Library           RW.Core
Library           RW.AWS.Billing
Suite Setup       Suite Initialization

*** Tasks ***
Get All Billing Sliced By Tags
    ${rsp}=    RW.AWS.Billing.Authenticate
    ...    ${AWS_ACCESS_KEY_ID}
    ...    ${AWS_SECRET_ACCESS_KEY}
    ...    ${REGION}
    ...    role_arn=${AWS_ROLE_ASSUME_ARN}
    ...    auth_mode=${AUTH_MODE}
    ${costs_per_tag}=    RW.AWS.Billing.Get Costs Per Tag    granularity=${GRANULARITY}    tag_dict=${TAGS_LIST}
    ${report}=    RW.AWS.Billing.Run Report On Tagged Costs    ${costs_per_tag}
    RW.Core.Add Pre To Report    ${report}

*** Keywords ***
Suite Initialization
    ${AWS_ACCESS_KEY_ID}=    Import Secret    aws_access_key_id
    ...    description=What AWS access key ID to use for authentication.
    ${AWS_SECRET_ACCESS_KEY}=    Import Secret    aws_secret_access_key
    ...    description=What AWS secret access key to use for authentication.
    ${AWS_ROLE_ASSUME_ARN}=    Import Secret    aws_assume_role_arn
    ...    description=Which role arn to assume if the role authentication flow is used.
    RW.Core.Import User Variable    AUTH_MODE
    ...    type=string
    ...    enum=[User,Role]
    ...    description=Determines the authentication flow when connecting to AWS services.
    ...    example=User
    RW.Core.Import User Variable    REGION
    ...    type=string
    ...    description=The AWS region to target resources in.
    ...    pattern=\w*
    ...    example=us-west-1
    RW.Core.Import User Variable    TAGS_LIST
    ...    type=string
    ...    description=A json blob representing the tags to include in queries.
    ...    pattern=\w*
    ...    example='{"mytag":"myvalue"}'
    RW.Core.Import User Variable    GRANULARITY
    ...    type=string
    ...    enum=[HOURLY,DAILY,MONTHLY]
    ...    description=The granularity of costs returned by the CostExplorer API.
    ...    example=MONTHLY
    Set Suite Variable    ${AWS_ACCESS_KEY_ID}    ${AWS_ACCESS_KEY_ID}
    Set Suite Variable    ${AWS_SECRET_ACCESS_KEY}    ${AWS_SECRET_ACCESS_KEY}
    Set Suite Variable    ${AWS_ROLE_ASSUME_ARN}    ${AWS_ROLE_ASSUME_ARN}
    Set Suite Variable    ${AUTH_MODE}    ${AUTH_MODE}
    Set Suite Variable    ${REGION}    ${REGION}
    Set Suite Variable    ${TAGS_LIST}    ${TAGS_LIST}
    Set Suite Variable    ${GRANULARITY}    ${GRANULARITY}
