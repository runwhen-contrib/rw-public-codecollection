*** Settings ***
Metadata          Author    Jonathan Funk
Metadata          Supports    aws,cloudwatch
Documentation     Retrieve aggregate results from multiple AWS Cloudwatch Metrics Insights queries ran against tagged resources.
...               This codebundle fetches a list of instance IDs filtered by tags, and uses them
...               to run a set of AWS metric queries against the CloudWatch metrics insights API
...               and pushes an aggregated/transformed value provided by the API as a metric.
Force Tags        AWS    CloudWatch    EC2    Multiple    Metrics    Metric    Query    Boto3    Errors    Failures
Library           RW.Core
Library           RW.AWS.EC2
Library           RW.AWS.CloudWatch
Suite Setup       Suite Initialization

*** Tasks ***
Run CloudWatch Metric Query Across Set Of IDs And Push Metric
    ${rsp}=    RW.AWS.EC2.Authenticate
    ...    ${AWS_ACCESS_KEY_ID}
    ...    ${AWS_SECRET_ACCESS_KEY}
    ...    ${REGION}
    ...    auth_mode=${AUTH_MODE}
    ...    role_arn=${AWS_ROLE_ASSUME_ARN}
    ${instance_ids}=    RW.AWS.EC2.Get Ec2 Instance Ids    tag_filter=${TAGS_LIST}
    ${rsp}=    RW.AWS.CloudWatch.Authenticate
    ...    ${AWS_ACCESS_KEY_ID}
    ...    ${AWS_SECRET_ACCESS_KEY}
    ...    ${REGION}
    ...    auth_mode=${AUTH_MODE}
    ...    role_arn=${AWS_ROLE_ASSUME_ARN}
    ${rsp}=    RW.AWS.CloudWatch.Multi Metric Query    ${CLOUDWATCH_METRIC_QUERY_TEMPLATE}    ${SECONDS_IN_PAST}
    ...    aws_ids=${instance_ids}
    ${metric}=    RW.AWS.CloudWatch.Transform Metric Dict    ${TRANSFORM}    ${rsp}
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
    RW.Core.Import User Variable    TRANSFORM
    ...    type=string
    ...    enum=[Max,Min,Average,Sum]
    ...    description=Determines how the CloudWatch results are aggregated/transformed.
    ...    example=Max
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
    ...    default='{}'
    RW.Core.Import User Variable
    ...    CLOUDWATCH_METRIC_QUERY_TEMPLATE
    ...    type=string
    ...    description=What templated CloudWatch Metrics Insights query to run against the CloudWatch Metrics API. You can use {variable} template notation in the query.
    ...    pattern=\w*
    ...    example=SELECT MAX(CPUUtilization) FROM "AWS/EC2"'
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
    Set Suite Variable    ${TRANSFORM}    ${TRANSFORM}
    Set Suite Variable    ${TAGS_LIST}    ${TAGS_LIST}
    Set Suite Variable    ${REGION}    ${REGION}
    Set Suite Variable    ${CLOUDWATCH_METRIC_QUERY_TEMPLATE}    ${CLOUDWATCH_METRIC_QUERY_TEMPLATE}
    Set Suite Variable    ${SECONDS_IN_PAST}    ${SECONDS_IN_PAST}
