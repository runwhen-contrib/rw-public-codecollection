*** Settings ***
Metadata          Author    Jonathan Funk
Metadata          Supports    aws,cloudwatch
Metadata          Display Name    AWS CloudWatch Metric Query Dashboard
Documentation     Creates a URL to a AWS CloudWatch metrics dashboard with a running query.
Force Tags        AWS    CloudWatch    Metrics    Metric    Query    Boto3    Errors    Failures    Link    Dashboard
Library           RW.Core
Library           RW.AWS.CloudWatch
Suite Setup       Suite Initialization

*** Tasks ***
Get CloudWatch MetricQuery Insights URL
    ${rsp}=    RW.AWS.CloudWatch.Get CloudWatch Metric Insights Url
    ...    ${REGION}
    ...    ${CLOUDWATCH_METRIC_QUERY}
    RW.Core.Add To Report    CloudWatch Metric Query URL:
    RW.Core.Add To Report    ${rsp}

*** Keywords ***
Suite Initialization
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
    Set Suite Variable    ${AWS_ACCESS_KEY_ID}    ${AWS_ACCESS_KEY_ID}
    Set Suite Variable    ${AWS_SECRET_ACCESS_KEY}    ${AWS_SECRET_ACCESS_KEY}
    Set Suite Variable    ${AWS_ROLE_ASSUME_ARN}    ${AWS_ROLE_ASSUME_ARN}
    Set Suite Variable    ${AUTH_MODE}    ${AUTH_MODE}
    Set Suite Variable    ${REGION}    ${REGION}
    Set Suite Variable    ${CLOUDWATCH_METRIC_QUERY}    ${CLOUDWATCH_METRIC_QUERY}
    Set Suite Variable    ${SECONDS_IN_PAST}    ${SECONDS_IN_PAST}
