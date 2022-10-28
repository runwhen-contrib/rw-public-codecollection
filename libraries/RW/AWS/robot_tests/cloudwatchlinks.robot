*** Settings ***
Library           RW.AWS.CloudWatch
Suite Setup       Suite Initialization
Variables         test_queries.py

*** Variables ***
${LOG_QUERY}      fields @timestamp, @message | sort @timestamp desc | limit 500
${SECONDS_IN_PAST}    3600

*** Tasks ***
Get CloudWatch LogQuery Insights URL
    ${rsp}=    RW.AWS.CloudWatch.Get CloudWatch Logs Insights Url
    ...    ${AWS_REGION}
    ...    ${LOG_QUERY}
    ...    ${AWS_LOG_GROUP}
    ...    ${SECONDS_IN_PAST}
    log    ${rsp}

Get CloudWatch MetricQuery Insights URL
    ${rsp}=    RW.AWS.CloudWatch.Get CloudWatch Metric Insights Url
    ...    ${AWS_REGION}
    ...    ${AWS_METRIC_QUERY}
    log    ${rsp}

Test AWS URL Encode
    ${rsp}=    RW.AWS.CloudWatch.AWS Encode Var    ${SAMPLE_METRIC_QUERY["metrics"][0]["expression"]}

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
