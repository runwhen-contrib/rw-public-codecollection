*** Settings ***
Metadata          Author    Jonathan Funk
Metadata          Supports    aws,billing,costexplorer
Documentation     Monitors AWS cost and usage data for the latest billing period.
...               Accepts one tag for continuous monitoring.
Force Tags        AWS    Cost    Billing    CostExplorer    Usage
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
    ${costs}=    RW.AWS.Billing.Get Cost And Usage
    ...    tag_key=${TAG_KEY}
    ...    tag_value=${TAG_VALUE}
    ${metric}=    RW.AWS.Billing.Get Cost Metric From Results    ${costs}    ${COST_METRIC}
    RW.Core.Push Metric    ${metric}

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
    RW.Core.Import User Variable    COST_METRIC
    ...    type=string
    ...    enum=[AmortizedCost,BlendedCost,NetAmortizedCost,NetUnblendedCost,NormalizedUsageAmount,UnblendedCost,UsageQuantity]
    ...    description=Which of the cost metric types to monitor for values. See https://docs.aws.amazon.com/cost-management/latest/userguide/ce-advanced.html
    ...    example=AmortizedCost
    RW.Core.Import User Variable    TAG_KEY
    ...    type=string
    ...    description=The value of the tag's key.
    ...    pattern=\w*
    ...    example='Name'
    RW.Core.Import User Variable    TAG_VALUE
    ...    type=string
    ...    description=The value of the tag's value.
    ...    pattern=\w*
    ...    example='MyAwesomeInstanceName'
    Set Suite Variable    ${AWS_ACCESS_KEY_ID}    ${AWS_ACCESS_KEY_ID}
    Set Suite Variable    ${AWS_SECRET_ACCESS_KEY}    ${AWS_SECRET_ACCESS_KEY}
    Set Suite Variable    ${AWS_ROLE_ASSUME_ARN}    ${AWS_ROLE_ASSUME_ARN}
    Set Suite Variable    ${AUTH_MODE}    ${AUTH_MODE}
    Set Suite Variable    ${REGION}    ${REGION}
    Set Suite Variable    ${COST_METRIC}    ${COST_METRIC}
    Set Suite Variable    ${TAG_KEY}    ${TAG_KEY}
    Set Suite Variable    ${TAG_VALUE}    ${TAG_VALUE}
