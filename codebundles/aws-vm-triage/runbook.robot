*** Settings ***
Documentation     Triage and troubleshoot performance and usage of an AWS EC2 instance
Metadata          Type    TaskSet
Metadata          Supports    aws,ec2,cloudwatch
Library           RW.Core
Library           RW.AWS.CloudWatch
Suite Setup       Suite Initialization

*** Tasks ***
Get Max VM CPU Utilization In Last 3 Hours
    ${METRIC_QUERY}=    Set Variable
    ...    SELECT MAX(CPUUtilization) FROM SCHEMA("AWS/EC2", InstanceId) WHERE InstanceId = '${VM_INSTANCE_ID}' GROUP BY InstanceId ORDER BY MAX() DESC
    ${rsp}=    RW.AWS.CloudWatch.Authenticate
    ...    ${AWS_ACCESS_KEY_ID}
    ...    ${AWS_SECRET_ACCESS_KEY}
    ...    ${REGION}
    ...    auth_mode=${AUTH_MODE}
    ...    role_arn=${AWS_ROLE_ASSUME_ARN}
    ${rsp}=    RW.AWS.CloudWatch.Metric Query    ${METRIC_QUERY}    ${MAX_METRIC_HISTORY}
    ${metric}=    RW.AWS.CloudWatch.Largest Metric From Results    ${rsp}
    RW.Core.Add To Report    VM 3-hour Maximum CPU Utilization For VM: ${VM_INSTANCE_ID}
    RW.Core.Add To Report    MAX(CPUUtilization):${metric}%

Get Lowest VM CPU Credits In Last 3 Hours
    ${METRIC_QUERY}=    Set Variable
    ...    SELECT MIN(CPUCreditBalance) FROM SCHEMA("AWS/EC2", InstanceId) WHERE InstanceId = '${VM_INSTANCE_ID}' GROUP BY InstanceId
    ${rsp}=    RW.AWS.CloudWatch.Authenticate
    ...    ${AWS_ACCESS_KEY_ID}
    ...    ${AWS_SECRET_ACCESS_KEY}
    ...    ${REGION}
    ...    auth_mode=${AUTH_MODE}
    ...    role_arn=${AWS_ROLE_ASSUME_ARN}
    ${rsp}=    RW.AWS.CloudWatch.Metric Query    ${METRIC_QUERY}    ${MAX_METRIC_HISTORY}
    ${metric}=    RW.AWS.CloudWatch.Smallest Metric From Results    ${rsp}
    RW.Core.Add To Report    VM 3-hour Minimum CPU Credit Balance For VM: ${VM_INSTANCE_ID}
    RW.Core.Add To Report    MIN(CPUCreditBalance):${metric}

Get Max VM CPU Credit Usage In Last 3 hours
    ${METRIC_QUERY}=    Set Variable
    ...    SELECT MAX(CPUCreditUsage) FROM SCHEMA("AWS/EC2", InstanceId) WHERE InstanceId = '${VM_INSTANCE_ID}' GROUP BY InstanceId ORDER BY MAX() DESC
    ${rsp}=    RW.AWS.CloudWatch.Authenticate
    ...    ${AWS_ACCESS_KEY_ID}
    ...    ${AWS_SECRET_ACCESS_KEY}
    ...    ${REGION}
    ...    auth_mode=${AUTH_MODE}
    ...    role_arn=${AWS_ROLE_ASSUME_ARN}
    ${rsp}=    RW.AWS.CloudWatch.Metric Query    ${METRIC_QUERY}    ${MAX_METRIC_HISTORY}
    ${metric}=    RW.AWS.CloudWatch.Largest Metric From Results    ${rsp}
    RW.Core.Add To Report    VM 3-hour Maximum CPU Credit Usage For VM: ${VM_INSTANCE_ID}
    RW.Core.Add To Report    MAX(CPUCreditUsage):${metric}

Get Max VM Memory Utilization In Last 3 Hours
    ${METRIC_QUERY}=    Set Variable
    ...    SELECT MAX(mem_used_percent) FROM SCHEMA(CWAgent, InstanceId) WHERE InstanceId = '${VM_INSTANCE_ID}' GROUP BY InstanceId
    ${rsp}=    RW.AWS.CloudWatch.Authenticate
    ...    ${AWS_ACCESS_KEY_ID}
    ...    ${AWS_SECRET_ACCESS_KEY}
    ...    ${REGION}
    ...    auth_mode=${AUTH_MODE}
    ...    role_arn=${AWS_ROLE_ASSUME_ARN}
    ${rsp}=    RW.AWS.CloudWatch.Metric Query    ${METRIC_QUERY}    ${MAX_METRIC_HISTORY}
    ${metric}=    RW.AWS.CloudWatch.Largest Metric From Results    ${rsp}
    RW.Core.Add To Report    VM 3-hour Maximum Memory Utilization For VM: ${VM_INSTANCE_ID}
    RW.Core.Add To Report    MAX(mem_used_percent):${metric}%

Get Max VM Volume Usage In Last 3 Hours
    ${METRIC_QUERY}=    Set Variable
    ...    SELECT MAX(disk_used_percent) FROM CWAgent WHERE path = '${VM_VOLUME_PATH}' AND InstanceId = '${VM_INSTANCE_ID}' GROUP BY InstanceId
    ${rsp}=    RW.AWS.CloudWatch.Authenticate
    ...    ${AWS_ACCESS_KEY_ID}
    ...    ${AWS_SECRET_ACCESS_KEY}
    ...    ${REGION}
    ...    auth_mode=${AUTH_MODE}
    ...    role_arn=${AWS_ROLE_ASSUME_ARN}
    ${rsp}=    RW.AWS.CloudWatch.Metric Query    ${METRIC_QUERY}    ${MAX_METRIC_HISTORY}
    ${metric}=    RW.AWS.CloudWatch.Largest Metric From Results    ${rsp}
    RW.Core.Add To Report    VM 3-hour Maximum Volume Usage For VM: ${VM_INSTANCE_ID}
    RW.Core.Add To Report    VOLUME:${VM_VOLUME_PATH} MAX(disk_used_percent):${metric}%

*** Keywords ***
Suite Initialization
    ${AWS_ACCESS_KEY_ID}=    Import Secret    aws_access_key_id
    ...    description=What AWS access key ID to use for authentication.
    ${AWS_SECRET_ACCESS_KEY}=    Import Secret    aws_secret_access_key
    ...    description=What AWS secret access key to use for authentication.
    ${AWS_ROLE_ASSUME_ARN}=    Import Secret    aws_assume_role_arn
    ...    description=Which role arn to assume if the role authentication flow is used.
    ${MAX_METRIC_HISTORY}=    Set Variable    10800
    RW.Core.Import User Variable    AUTH_MODE
    RW.Core.Import User Variable    REGION
    RW.Core.Import User Variable    VM_INSTANCE_ID
    RW.Core.Import User Variable    VM_VOLUME_PATH
    Set Suite Variable    ${AWS_ACCESS_KEY_ID}    ${AWS_ACCESS_KEY_ID}
    Set Suite Variable    ${AWS_SECRET_ACCESS_KEY}    ${AWS_SECRET_ACCESS_KEY}
    Set Suite Variable    ${AWS_ROLE_ASSUME_ARN}    ${AWS_ROLE_ASSUME_ARN}
    Set Suite Variable    ${AUTH_MODE}    ${AUTH_MODE}
    Set Suite Variable    ${MAX_METRIC_HISTORY}    ${MAX_METRIC_HISTORY}
    Set Suite Variable    ${REGION}    ${REGION}
    Set Suite Variable    ${VM_INSTANCE_ID}    ${VM_INSTANCE_ID}
    Set Suite Variable    ${VM_VOLUME_PATH}    ${VM_VOLUME_PATH}
