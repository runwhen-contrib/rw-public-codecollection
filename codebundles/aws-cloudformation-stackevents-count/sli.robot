*** Settings ***
Metadata          Author    Jonathan Funk
Metadata          Supports    aws,cloudformation
Metadata          Display Name    AWS CloudFormation Event Rate
Documentation     Retrieve the number of detected AWS CloudFormation stack events over a given history
Force Tags        AWS    CloudFormation    Boto3    Stack Events    Stacks    Errors    Failures
Library           RW.Core
Library           RW.AWS.CloudFormation
Suite Setup       Suite Initialization

*** Tasks ***
Fetch CloudFormation Stack Events
    ${rsp}=    RW.AWS.CloudFormation.Authenticate
    ...    ${AWS_ACCESS_KEY_ID}
    ...    ${AWS_SECRET_ACCESS_KEY}
    ...    ${REGION}
    ...    auth_mode=${AUTH_MODE}
    ...    role_arn=${AWS_ROLE_ASSUME_ARN}
    ${events}=    RW.AWS.CloudFormation.Get All Stack Events    ${EVENT_STATUS}    ${SECONDS_IN_PAST}
    ${metric}=    Evaluate    len($events)
    Log    result: ${events}
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
    ...    default=User
    RW.Core.Import User Variable    REGION
    ...    type=string
    ...    description=The AWS region to target resources in.
    ...    pattern=\w*
    ...    example=us-west-1
    RW.Core.Import User Variable
    ...    EVENT_STATUS
    ...    type=string
    ...    enum=[CREATE_IN_PROGRESS,CREATE_FAILED,CREATE_COMPLETE,DELETE_IN_PROGRESS,DELETE_FAILED,DELETE_COMPLETE,DELETE_SKIPPED,UPDATE_IN_PROGRESS,UPDATE_FAILED,UPDATE_COMPLETE,IMPORT_FAILED,IMPORT_COMPLETE,IMPORT_IN_PROGRESS,IMPORT_ROLLBACK_IN_PROGRESS,IMPORT_ROLLBACK_FAILED,IMPORT_ROLLBACK_COMPLETE,UPDATE_ROLLBACK_IN_PROGRESS,UPDATE_ROLLBACK_COMPLETE,UPDATE_ROLLBACK_FAILED,ROLLBACK_IN_PROGRESS,ROLLBACK_COMPLETE,ROLLBACK_FAILED]
    ...    description=Which stack event status to count occurences of.
    ...    example=CREATE_FAILED
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
    Set Suite Variable    ${EVENT_STATUS}    ${EVENT_STATUS}
    Set Suite Variable    ${SECONDS_IN_PAST}    ${SECONDS_IN_PAST}
