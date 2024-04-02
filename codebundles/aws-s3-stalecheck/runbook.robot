*** Settings ***
Metadata          Author    Jonathan Funk
Metadata          Type    TaskSet
Metadata          Supports    aws,s3,bucket
Documentation     Identify stale AWS S3 buckets, based on last modified object timestamp.
Force Tags        AWS    Storage    S3    Bucket    Metrics    Metric    Query    Boto3    Objects    Stale
Library           RW.Core
Library           RW.AWS.S3
Suite Setup       Suite Initialization

*** Tasks ***
Create Report For Stale Buckets
    ${rsp}=    RW.AWS.S3.Authenticate
    ...    ${AWS_ACCESS_KEY_ID}
    ...    ${AWS_SECRET_ACCESS_KEY}
    ...    ${REGION}
    ...    auth_mode=${AUTH_MODE}
    ...    role_arn=${AWS_ROLE_ASSUME_ARN}
    ${report}=    RW.AWS.S3.Run S3 Checks    region_name=${REGION}    days_stale_threshold=${DAYS_STALE_THRESHOLD}
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
    RW.Core.Import User Variable
    ...    DAYS_STALE_THRESHOLD
    ...    type=string
    ...    description=The number of days of no activity allowed before a bucket is considered stale.
    ...    pattern="^[0-9]*$"
    ...    example=90
    ...    default=90
    Set Suite Variable    ${AWS_ACCESS_KEY_ID}    ${AWS_ACCESS_KEY_ID}
    Set Suite Variable    ${AWS_SECRET_ACCESS_KEY}    ${AWS_SECRET_ACCESS_KEY}
    Set Suite Variable    ${AWS_ROLE_ASSUME_ARN}    ${AWS_ROLE_ASSUME_ARN}
    Set Suite Variable    ${AUTH_MODE}    ${AUTH_MODE}
    Set Suite Variable    ${REGION}    ${REGION}
    Set Suite Variable    ${DAYS_STALE_THRESHOLD}    ${DAYS_STALE_THRESHOLD}
