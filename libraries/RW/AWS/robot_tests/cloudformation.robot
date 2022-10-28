*** Settings ***
Library           RW.AWS.CloudFormation
Suite Setup       Suite Initialization

*** Variables ***
${STACK_EVENT_STATUS}    CREATE_IN_PROGRESS
${SECONDS_IN_PAST}    3600

*** Tasks ***
Fetch CloudFormation All Stack Events Under Name
    ${rsp}=    RW.AWS.CloudFormation.Authenticate
    ...    ${AWS_ACCESS_KEY_ID}
    ...    ${AWS_SECRET_ACCESS_KEY}
    ...    ${AWS_REGION}
    ...    role_arn=${AWS_ROLE_ASSUME_ARN}
    ...    auth_mode=Role
    ${rsp}=    RW.AWS.CloudFormation.Get Stack Events    ${AWS_STACK_NAME}
    ${events}=    RW.AWS.CloudFormation.Filter Stack Events By Status    ${rsp}    ${STACK_EVENT_STATUS}
    ${events}=    RW.AWS.CloudFormation.Filter Stack Events By Time    ${events}    ${SECONDS_IN_PAST}
    ${event_rows}=    Set Variable    ${events}
    ${metric}=    Evaluate    len($event_rows)

Fetch CloudFormation Stack Events In Last Hour
    ${rsp}=    RW.AWS.CloudFormation.Authenticate
    ...    ${AWS_ACCESS_KEY_ID}
    ...    ${AWS_SECRET_ACCESS_KEY}
    ...    ${AWS_REGION}
    ...    role_arn=${AWS_ROLE_ASSUME_ARN}
    ...    auth_mode=Role
    ${rsp}=    RW.AWS.CloudFormation.Get Stack Events    ${AWS_STACK_NAME}
    ${events}=    RW.AWS.CloudFormation.Filter Stack Events By Time    ${rsp}    ${SECONDS_IN_PAST}
    ${event_rows}=    Set Variable    ${events}
    ${metric}=    Evaluate    len($event_rows)

Fetch CloudFormation Stack Events With Status
    ${rsp}=    RW.AWS.CloudFormation.Authenticate
    ...    ${AWS_ACCESS_KEY_ID}
    ...    ${AWS_SECRET_ACCESS_KEY}
    ...    ${AWS_REGION}
    ...    role_arn=${AWS_ROLE_ASSUME_ARN}
    ...    auth_mode=Role
    ${rsp}=    RW.AWS.CloudFormation.Get Stack Events    ${AWS_STACK_NAME}
    ${events}=    RW.AWS.CloudFormation.Filter Stack Events By Status    ${rsp}    ${STACK_EVENT_STATUS}
    ${event_rows}=    Set Variable    ${events}
    ${metric}=    Evaluate    len($event_rows)

Fetch Stack Summaries
    ${rsp}=    RW.AWS.CloudFormation.Authenticate
    ...    ${AWS_ACCESS_KEY_ID}
    ...    ${AWS_SECRET_ACCESS_KEY}
    ...    ${AWS_REGION}
    ...    role_arn=${AWS_ROLE_ASSUME_ARN}
    ...    auth_mode=Role
    ${rsp}=    RW.AWS.CloudFormation.Get Stack Summaries

Fetch All Stack Events Across All Stacks With Status
    ${rsp}=    RW.AWS.CloudFormation.Authenticate
    ...    ${AWS_ACCESS_KEY_ID}
    ...    ${AWS_SECRET_ACCESS_KEY}
    ...    ${AWS_REGION}
    ...    role_arn=${AWS_ROLE_ASSUME_ARN}
    ...    auth_mode=Role
    ${rsp}=    RW.AWS.CloudFormation.Get All Stack Events    CREATE_COMPLETE

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
    Set Suite Variable    ${AWS_STACK_NAME}    %{AWS_STACK_NAME}
