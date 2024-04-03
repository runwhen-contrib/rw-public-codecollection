*** Settings ***
Metadata          Author    Jonathan Funk
Metadata          Supports    aws,cloudwatch
Metadata          Display Name    AWS CloudWatch Log Query (Pass/Fail)
Documentation     Retrieve binary result from an AWS CloudWatch Insights query.
...               Pushes 0 (success) if logs are found (activity) or 1 if no logs were found in the time window.
Force Tags        AWS    CloudWatch    Logs    Query    Log Group    Boto3    Errors    Failures    Files    Heart beat
Library           RW.Core
Library           RW.AWS.CloudWatch

*** Tasks ***
Running CloudWatch Log Query And Pushing 1 If No Results Found
    ${rsp}=    RW.AWS.CloudWatch.Authenticate
    ...    ${AWS_ACCESS_KEY_ID}
    ...    ${AWS_SECRET_ACCESS_KEY}
    ...    ${REGION}
    ...    auth_mode=${AUTH_MODE}
    ...    role_arn=${AWS_ROLE_ASSUME_ARN}
    ${rsp}=    RW.AWS.CloudWatch.Log Query    ${CLOUDWATCH_LOG_GROUP}    ${CLOUDWATCH_LOG_QUERY}    ${SECONDS_IN_PAST}
    ${result_rows}=    Set Variable    ${rsp['results']}
    ${count}=    Evaluate    len($result_rows)
    ${metric}=    Evaluate    0 if ${count} > 0 else 1
    Log    response: ${rsp}
    Log    result: ${result_rows}
    Log    count: ${count}
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
    RW.Core.Import User Variable    CLOUDWATCH_LOG_GROUP
    ...    type=string
    ...    description=The Log group to query for logs.
    ...    pattern=\w*
    ...    example=MyCloudWatchLogGroup
    RW.Core.Import User Variable    CLOUDWATCH_LOG_QUERY
    ...    type=string
    ...    description=The CloudWatch query to run. You can paste query strings from the CloudWatch Logquery editor here.
    ...    pattern=\w*
    ...    example=fields @timestamp, @message, @logStream | sort @timestamp desc | limit 500
    RW.Core.Import User Variable    SECONDS_IN_PAST
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
    Set Suite Variable    ${CLOUDWATCH_LOG_GROUP}    ${CLOUDWATCH_LOG_GROUP}
    Set Suite Variable    ${CLOUDWATCH_LOG_QUERY}    ${CLOUDWATCH_LOG_QUERY}
    Set Suite Variable    ${SECONDS_IN_PAST}    ${SECONDS_IN_PAST}
