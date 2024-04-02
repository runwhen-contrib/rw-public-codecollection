*** Settings ***
Metadata          Author    Jonathan Funk
Metadata          Supports    aws,cloudwatch
Documentation     Retrieve the result of an AWS CloudWatch Metrics Insights query.
Force Tags        AWS    CloudWatch    Metrics    Metric    Query    Boto3    Errors    Failures
Library           RW.Core
Library           RW.AWS.CloudWatch
Suite Setup       Suite Initialization

*** Tasks ***
Running CloudWatch Metric Query And Pushing The Result
    ${rsp}=    RW.AWS.CloudWatch.Authenticate    ${aws_access_key_id}
    ...    ${aws_secret_access_key}
    ...    ${REGION}
    ...    auth_mode=${AUTH_MODE}
    ...    role_arn=${AWS_ROLE_ASSUME_ARN}
    ${rsp}=    RW.AWS.CloudWatch.Metric Query    ${CLOUDWATCH_METRIC_QUERY}    ${SECONDS_IN_PAST}
    ${metric}=    RW.AWS.CloudWatch.Most Recent Metric From Results    ${rsp}
    Log    result: ${rsp}
    Log    metric value: ${metric}
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
    RW.Core.Import User Variable
    ...    CLOUDWATCH_METRIC_QUERY
    ...    type=string
    ...    description=The CloudWatch query to run. You can paste query strings from the CloudWatch Metric Insights editor here.
    ...    pattern=\w*
    ...    example=SELECT MAX(CPUUtilization) FROM "AWS/EC2"
    RW.Core.Import User Variable
    ...    SECONDS_IN_PAST
    ...    type=string
    ...    description=The number of seconds of history to consider for SLI values. Depends on provider's sampling rate. Consider 600 as a starter.
    ...    pattern="^[0-9]*$"
    ...    example=600
    ...    default=600
    Set Suite Variable    ${AWS_ACCESS_KEY_ID}    ${AWS_ACCESS_KEY_ID}
    Set Suite Variable    ${AWS_SECRET_ACCESS_KEY}    ${AWS_SECRET_ACCESS_KEY}
    Set Suite Variable    ${AWS_ROLE_ASSUME_ARN}    ${AWS_ROLE_ASSUME_ARN}
    Set Suite Variable    ${AUTH_MODE}    ${AUTH_MODE}
    Set Suite Variable    ${REGION}    ${REGION}
    Set Suite Variable    ${CLOUDWATCH_METRIC_QUERY}    ${CLOUDWATCH_METRIC_QUERY}
    Set Suite Variable    ${SECONDS_IN_PAST}    ${SECONDS_IN_PAST}
