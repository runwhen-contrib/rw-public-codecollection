*** Settings ***
Library           RW.AWS.Billing
Suite Setup       Suite Initialization

*** Variables ***
${SECONDS_IN_PAST}    3600

*** Tasks ***
Get All Billing As Monthly
    ${rsp}=    RW.AWS.Billing.Authenticate
    ...    ${AWS_ACCESS_KEY_ID}
    ...    ${AWS_SECRET_ACCESS_KEY}
    ...    ${AWS_REGION}
    ...    role_arn=${AWS_ROLE_ASSUME_ARN}
    ...    auth_mode=Role
    ${costs}=    RW.AWS.Billing.Get Cost And Usage
    Log    ${costs}

Get All Billing As Monthly With Tags
    ${rsp}=    RW.AWS.Billing.Authenticate
    ...    ${AWS_ACCESS_KEY_ID}
    ...    ${AWS_SECRET_ACCESS_KEY}
    ...    ${AWS_REGION}
    ...    role_arn=${AWS_ROLE_ASSUME_ARN}
    ...    auth_mode=Role
    ${costs}=    RW.AWS.Billing.Get Cost And Usage
    ...    tag_key="group"
    ...    tag_value="metrics"
    Log    ${costs}

Create Daily Billing Report
    ${rsp}=    RW.AWS.Billing.Authenticate
    ...    ${AWS_ACCESS_KEY_ID}
    ...    ${AWS_SECRET_ACCESS_KEY}
    ...    ${AWS_REGION}
    ...    role_arn=${AWS_ROLE_ASSUME_ARN}
    ...    auth_mode=Role
    ${TAG_FILTER}    Evaluate    '''{"group":"metrics"}'''
    ${costs_per_tag}=    RW.AWS.Billing.Get Costs Per Tag    granularity=DAILY    tag_dict=${TAG_FILTER}
    ${report}=    RW.AWS.Billing.Run Report On Tagged Costs    ${costs_per_tag}
    Log    ${report}

Create Monthly Billing Report
    ${rsp}=    RW.AWS.Billing.Authenticate
    ...    ${AWS_ACCESS_KEY_ID}
    ...    ${AWS_SECRET_ACCESS_KEY}
    ...    ${AWS_REGION}
    ...    role_arn=${AWS_ROLE_ASSUME_ARN}
    ...    auth_mode=Role
    ${TAG_FILTER}    Evaluate    '''{"group":"metrics"}'''
    ${costs_per_tag}=    RW.AWS.Billing.Get Costs Per Tag    granularity=Monthly    tag_dict=${TAG_FILTER}
    ${report}=    RW.AWS.Billing.Run Report On Tagged Costs    ${costs_per_tag}
    Log    ${report}

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
