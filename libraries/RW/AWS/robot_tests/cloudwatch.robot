*** Settings ***
Library           RW.AWS.CloudWatch
Suite Setup       Suite Initialization

*** Variables ***
${SECONDS_IN_PAST}    3600
${LOG_QUERY}      fields @timestamp, @message | sort @timestamp desc | limit 500

*** Tasks ***
Run Cloudwatch Metric Insights Query With User Authentication
    ${rsp}=    RW.AWS.CloudWatch.Authenticate
    ...    ${AWS_USER_ACCESS_KEY_ID}
    ...    ${AWS_USER_SECRET_ACCESS_KEY}
    ...    ${AWS_USER_REGION}
    ...    auth_mode=User
    ${rsp}=    RW.AWS.CloudWatch.Metric Query    ${AWS_METRIC_QUERY}    ${SECONDS_IN_PAST}
    ${metric}=    RW.AWS.CloudWatch.Most Recent Metric From Results    ${rsp}

Run Cloudwatch Metric Insights Query
    ${rsp}=    RW.AWS.CloudWatch.Authenticate
    ...    ${AWS_ACCESS_KEY_ID}
    ...    ${AWS_SECRET_ACCESS_KEY}
    ...    ${AWS_REGION}
    ...    role_arn=${AWS_ROLE_ASSUME_ARN}
    ...    auth_mode=Role
    ${rsp}=    RW.AWS.CloudWatch.Metric Query    ${AWS_METRIC_QUERY}    ${SECONDS_IN_PAST}
    ${metric}=    RW.AWS.CloudWatch.Most Recent Metric From Results    ${rsp}

Run Cloudwatch Log Query
    ${rsp}=    RW.AWS.CloudWatch.Authenticate
    ...    ${AWS_ACCESS_KEY_ID}
    ...    ${AWS_SECRET_ACCESS_KEY}
    ...    ${AWS_REGION}
    ...    role_arn=${AWS_ROLE_ASSUME_ARN}
    ...    auth_mode=Role
    ${rsp}=    RW.AWS.CloudWatch.Log Query    ${AWS_LOG_GROUP}    ${LOG_QUERY}    ${SECONDS_IN_PAST}
    ${result_rows}=    Set Variable    ${rsp['results']}
    ${metric}=    Evaluate    len($result_rows)

Run Query Many Times With Alternating Authentication Flows
    ${rsp}=    RW.AWS.CloudWatch.Authenticate
    ...    ${AWS_ACCESS_KEY_ID}
    ...    ${AWS_SECRET_ACCESS_KEY}
    ...    ${AWS_REGION}
    ...    role_arn=${AWS_ROLE_ASSUME_ARN}
    ...    auth_mode=Role
    ${rsp}=    RW.AWS.CloudWatch.Log Query    ${AWS_LOG_GROUP}    ${LOG_QUERY}    ${SECONDS_IN_PAST}
    ${rsp}=    RW.AWS.CloudWatch.Authenticate
    ...    ${AWS_USER_ACCESS_KEY_ID}
    ...    ${AWS_USER_SECRET_ACCESS_KEY}
    ...    ${AWS_USER_REGION}
    ${rsp}=    RW.AWS.CloudWatch.Log Query    ${AWS_LOG_GROUP}    ${LOG_QUERY}    ${SECONDS_IN_PAST}
    ${rsp}=    RW.AWS.CloudWatch.Authenticate
    ...    ${AWS_ACCESS_KEY_ID}
    ...    ${AWS_SECRET_ACCESS_KEY}
    ...    ${AWS_REGION}
    ...    role_arn=${AWS_ROLE_ASSUME_ARN}
    ...    auth_mode=Role
    ${rsp}=    RW.AWS.CloudWatch.Log Query    ${AWS_LOG_GROUP}    ${LOG_QUERY}    ${SECONDS_IN_PAST}
    ${rsp}=    RW.AWS.CloudWatch.Log Query    ${AWS_LOG_GROUP}    ${LOG_QUERY}    ${SECONDS_IN_PAST}
    ${rsp}=    RW.AWS.CloudWatch.Log Query    ${AWS_LOG_GROUP}    ${LOG_QUERY}    ${SECONDS_IN_PAST}
    ${result_rows}=    Set Variable    ${rsp['results']}
    ${metric}=    Evaluate    len($result_rows)

*** Keywords ***
Suite Initialization
    # used for testing user auth method
    ${AWS_USER_ACCESS_KEY_ID}=    Evaluate    RW.platform.Secret("aws_access_key_id", """%{AWS_USER_ACCESS_KEY_ID}""")
    Set Suite Variable    ${AWS_USER_ACCESS_KEY_ID}    ${AWS_USER_ACCESS_KEY_ID}
    ${AWS_USER_SECRET_ACCESS_KEY}=    Evaluate    RW.platform.Secret("aws_secret_access_key", """%{AWS_USER_SECRET_ACCESS_KEY}""")
    Set Suite Variable    ${AWS_USER_SECRET_ACCESS_KEY}    ${AWS_USER_SECRET_ACCESS_KEY}
    Set Suite Variable    ${AWS_USER_REGION}    %{AWS_USER_REGION}
    # standard role based auth
    ${AWS_ACCESS_KEY_ID}=    Evaluate    RW.platform.Secret("aws_access_key_id", """%{AWS_ACCESS_KEY_ID}""")
    Set Suite Variable    ${AWS_ACCESS_KEY_ID}    ${AWS_ACCESS_KEY_ID}
    ${AWS_SECRET_ACCESS_KEY}=    Evaluate    RW.platform.Secret("aws_secret_access_key", """%{AWS_SECRET_ACCESS_KEY}""")
    Set Suite Variable    ${AWS_SECRET_ACCESS_KEY}    ${AWS_SECRET_ACCESS_KEY}
    Set Suite Variable    ${AWS_REGION}    %{AWS_REGION}
    ${AWS_ROLE_ASSUME_ARN}=    Evaluate    RW.platform.Secret("aws_role_assume_arn", """%{AWS_ROLE_ASSUME_ARN}""")
    Set Suite Variable    ${AWS_ROLE_ASSUME_ARN}    ${AWS_ROLE_ASSUME_ARN}
    # Test config
    Set Suite Variable    ${AWS_METRIC_QUERY}    %{AWS_METRIC_QUERY}
    Set Suite Variable    ${AWS_LOG_GROUP}    %{AWS_LOG_GROUP}
