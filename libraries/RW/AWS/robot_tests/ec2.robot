*** Settings ***
Library           RW.AWS.EC2
Suite Setup       Suite Initialization

*** Variables ***
${SECONDS_IN_PAST}    3600

*** Tasks ***
Get All EC2 Instances
    ${rsp}=    RW.AWS.EC2.Authenticate
    ...    ${AWS_ACCESS_KEY_ID}
    ...    ${AWS_SECRET_ACCESS_KEY}
    ...    ${AWS_REGION}
    ...    role_arn=${AWS_ROLE_ASSUME_ARN}
    ...    auth_mode=Role
    ${instances}=    RW.AWS.EC2.Get EC2 Instances
    Log    ${instances}
    ${count}    Evaluate    len($instances)
    Log    ${count}

Get All EC2 Instances Filtered By Tags
    ${rsp}=    RW.AWS.EC2.Authenticate
    ...    ${AWS_ACCESS_KEY_ID}
    ...    ${AWS_SECRET_ACCESS_KEY}
    ...    ${AWS_REGION}
    ...    role_arn=${AWS_ROLE_ASSUME_ARN}
    ...    auth_mode=Role
    ${TAG_FILTER}    Evaluate    {"group":"metrics"}
    ${instances}=    RW.AWS.EC2.Get EC2 Instances
    ...    tag_filter=${TAG_FILTER}
    Log    ${instances}
    ${count}    Evaluate    len($instances)
    Log    ${count}

Get All VPCs
    ${rsp}=    RW.AWS.EC2.Authenticate
    ...    ${AWS_ACCESS_KEY_ID}
    ...    ${AWS_SECRET_ACCESS_KEY}
    ...    ${AWS_REGION}
    ...    role_arn=${AWS_ROLE_ASSUME_ARN}
    ...    auth_mode=Role
    ${vpcs}=    RW.AWS.EC2.Get VPCs
    Log    ${vpcs}
    ${count}    Evaluate    len($vpcs)
    Log    ${count}

Get All Subnets
    ${rsp}=    RW.AWS.EC2.Authenticate
    ...    ${AWS_ACCESS_KEY_ID}
    ...    ${AWS_SECRET_ACCESS_KEY}
    ...    ${AWS_REGION}
    ...    role_arn=${AWS_ROLE_ASSUME_ARN}
    ...    auth_mode=Role
    ${vpcs}=    RW.AWS.EC2.Get Subnets
    Log    ${vpcs}
    ${count}    Evaluate    len($vpcs)
    Log    ${count}

Get All Route Tables
    ${rsp}=    RW.AWS.EC2.Authenticate
    ...    ${AWS_ACCESS_KEY_ID}
    ...    ${AWS_SECRET_ACCESS_KEY}
    ...    ${AWS_REGION}
    ...    role_arn=${AWS_ROLE_ASSUME_ARN}
    ...    auth_mode=Role
    ${tables}=    RW.AWS.EC2.Get Route Tables
    Log    ${tables}
    ${count}    Evaluate    len($tables)
    Log    ${count}

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
