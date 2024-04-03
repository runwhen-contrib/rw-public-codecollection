*** Settings ***
Metadata          Author    Jonathan Funk
Metadata          Supports    aws,ec2,cloudwatch
Metadata          Display Name    AWS EC2 Security Check
Documentation     Performs a suite of security checks against a set of AWS EC2 instances.
...               Checks include untagged instances, dangling volumes, open routes.
Force Tags        AWS    CloudWatch    Metrics    Metric    Query    Boto3    Errors    Failures
Library           RW.Core
Library           RW.AWS.CloudWatch
Library           RW.AWS.EC2
Suite Setup       Suite Initialization

*** Tasks ***
Check For Untagged instances
    ${rsp}=    RW.AWS.EC2.Authenticate
    ...    ${AWS_ACCESS_KEY_ID}
    ...    ${AWS_SECRET_ACCESS_KEY}
    ...    ${REGION}
    ...    auth_mode=${AUTH_MODE}
    ...    role_arn=${AWS_ROLE_ASSUME_ARN}
    ${instances}=    RW.AWS.EC2.Get Untagged Instances
    ${instance_ids}=    RW.AWS.EC2.Get Ec2 Instance Ids    ${instances}
    ${report}=    RW.AWS.EC2.Run Untagged Ec2 Checks    ${REGION}    ${instance_ids}
    RW.Core.Add Pre To Report    ${report}

Check For Dangling Volumes
    ${rsp}=    RW.AWS.EC2.Authenticate
    ...    ${AWS_ACCESS_KEY_ID}
    ...    ${AWS_SECRET_ACCESS_KEY}
    ...    ${REGION}
    ...    auth_mode=${AUTH_MODE}
    ...    role_arn=${AWS_ROLE_ASSUME_ARN}
    ${all_volumes}=    RW.AWS.EC2.Get Volumes    tag_filter=${TAGS_LIST}
    ${dangling_volumes}=    RW.AWS.EC2.Get Volumes With No Attachments    volume_list=${all_volumes}
    ${dangling_volume_ids}=    RW.AWS.EC2.Get Volume Ids    volume_list=${dangling_volumes}
    ${report}=    RW.AWS.EC2.Run Dangling Volumes Check    region_name=${REGION}    dangling_volumes=${dangling_volume_ids}
    RW.Core.Add Pre To Report    ${report}

Check For Open Routes
    ${rsp}=    RW.AWS.EC2.Authenticate
    ...    ${AWS_ACCESS_KEY_ID}
    ...    ${AWS_SECRET_ACCESS_KEY}
    ...    ${REGION}
    ...    auth_mode=${AUTH_MODE}
    ...    role_arn=${AWS_ROLE_ASSUME_ARN}
    ${route_tables}=    RW.AWS.EC2.Get Route Tables
    ${open_routes}=    RW.AWS.EC2.Find Open Routes    ${route_tables}
    ${instances}=    RW.AWS.EC2.Get Ec2 Instances
    ${vpc_ids}=    RW.AWS.EC2.Get Vpcs Ids From Instances    ${instances}
    ${open_vpc_ids}=    Evaluate    [open_route["VpcId"] for open_route in ${open_routes} if "VpcId" in open_route]
    ${open_instances}=    RW.AWS.EC2.Filter Dicts With List    ${instances}    VpcId    ${open_vpc_ids}
    ${instance_ids}=    RW.AWS.EC2.Get Ec2 Instance Ids    ${open_instances}
    ${report}=    RW.AWS.EC2.Run Untagged Ec2 Checks    ${REGION}    ${instance_ids}
    RW.Core.Add Pre To Report    ${report}

Check For Overused Instances
    ${rsp}=    RW.AWS.EC2.Authenticate
    ...    ${AWS_ACCESS_KEY_ID}
    ...    ${AWS_SECRET_ACCESS_KEY}
    ...    ${REGION}
    ...    auth_mode=${AUTH_MODE}
    ...    role_arn=${AWS_ROLE_ASSUME_ARN}
    ${rsp}=    RW.AWS.CloudWatch.Authenticate
    ...    ${AWS_ACCESS_KEY_ID}
    ...    ${AWS_SECRET_ACCESS_KEY}
    ...    ${REGION}
    ...    auth_mode=${AUTH_MODE}
    ...    role_arn=${AWS_ROLE_ASSUME_ARN}
    ${instances}=    RW.AWS.EC2.Get Ec2 Instances    tag_filter=${TAGS_LIST}
    ${instance_ids}=    RW.AWS.EC2.Get Ec2 Instance Ids    instance_list=${instances}
    ${instance_cpu_utils}=    RW.AWS.CloudWatch.Multi Metric Query    SELECT AVG(CPUUtilization) FROM "AWS/EC2" WHERE InstanceId = '{aws_id}'    ${SECONDS_IN_PAST}
    ...    aws_ids=${instance_ids}
    ${overrused_cpu}=    RW.AWS.CloudWatch.Filter Metric Dict    ${instance_cpu_utils}    Less Than    ${OVERUSED_CPU_THRESHOLD}
    ${report}=    RW.AWS.EC2.Run Resourcing Check    region_name=${REGION}    resource_dict=${overrused_cpu}    resource_name=Over-utilized EC2 CPU    check_title=EC2 CPU Over-utilization Check
    RW.Core.Add Pre To Report    ${report}

Check For Underused Instances
    ${rsp}=    RW.AWS.EC2.Authenticate
    ...    ${AWS_ACCESS_KEY_ID}
    ...    ${AWS_SECRET_ACCESS_KEY}
    ...    ${REGION}
    ...    auth_mode=${AUTH_MODE}
    ...    role_arn=${AWS_ROLE_ASSUME_ARN}
    ${rsp}=    RW.AWS.CloudWatch.Authenticate
    ...    ${AWS_ACCESS_KEY_ID}
    ...    ${AWS_SECRET_ACCESS_KEY}
    ...    ${REGION}
    ...    auth_mode=${AUTH_MODE}
    ...    role_arn=${AWS_ROLE_ASSUME_ARN}
    ${instances}=    RW.AWS.EC2.Get Ec2 Instances    tag_filter=${TAGS_LIST}
    ${instance_ids}=    RW.AWS.EC2.Get Ec2 Instance Ids    instance_list=${instances}
    ${instance_cpu_utils}=    RW.AWS.CloudWatch.Multi Metric Query    SELECT AVG(CPUUtilization) FROM "AWS/EC2" WHERE InstanceId = '{aws_id}'    ${SECONDS_IN_PAST}
    ...    aws_ids=${instance_ids}
    ${underused_cpus}=    RW.AWS.CloudWatch.Filter Metric Dict    ${instance_cpu_utils}    Greater Than    ${UNDERUSED_CPU_THRESHOLD}
    ${report}=    RW.AWS.EC2.Run Resourcing Check    region_name=${REGION}    resource_dict=${underused_cpus}    resource_name=Under-utilized EC2 CPU    check_title=EC2 CPU Under-utilization Check
    RW.Core.Add Pre To Report    ${report}

Check For Underused Volumes
    ${rsp}=    RW.AWS.EC2.Authenticate
    ...    ${AWS_ACCESS_KEY_ID}
    ...    ${AWS_SECRET_ACCESS_KEY}
    ...    ${REGION}
    ...    auth_mode=${AUTH_MODE}
    ...    role_arn=${AWS_ROLE_ASSUME_ARN}
    ${rsp}=    RW.AWS.CloudWatch.Authenticate
    ...    ${AWS_ACCESS_KEY_ID}
    ...    ${AWS_SECRET_ACCESS_KEY}
    ...    ${REGION}
    ...    auth_mode=${AUTH_MODE}
    ...    role_arn=${AWS_ROLE_ASSUME_ARN}
    ${volumes}=    RW.AWS.EC2.Get Volumes    tag_filter=${TAGS_LIST}
    ${volume_device_usages}=    RW.AWS.CloudWatch.Get Volume Usages    volume_list=${volumes}    volume_device_remaps=${DEVICE_REMAPS}
    ${underused_volumes}=    RW.AWS.CloudWatch.Filter Metric Dict    ${volume_device_usages}    Greater Than    ${UNDERUSED_VOLUME_THRESHOLD}
    ${report}=    RW.AWS.EC2.Run Resourcing Check    region_name=${REGION}    resource_dict=${underused_volumes}    resource_name=Under-utilized EBS volumes    check_title=EBS Volume Over Utilization Check
    RW.Core.Add Pre To Report    ${report}

Check For Overused Volumes
    ${rsp}=    RW.AWS.EC2.Authenticate
    ...    ${AWS_ACCESS_KEY_ID}
    ...    ${AWS_SECRET_ACCESS_KEY}
    ...    ${REGION}
    ...    auth_mode=${AUTH_MODE}
    ...    role_arn=${AWS_ROLE_ASSUME_ARN}
    ${rsp}=    RW.AWS.CloudWatch.Authenticate
    ...    ${AWS_ACCESS_KEY_ID}
    ...    ${AWS_SECRET_ACCESS_KEY}
    ...    ${REGION}
    ...    auth_mode=${AUTH_MODE}
    ...    role_arn=${AWS_ROLE_ASSUME_ARN}
    ${volumes}=    RW.AWS.EC2.Get Volumes    tag_filter=${TAGS_LIST}
    ${volume_device_usages}=    RW.AWS.CloudWatch.Get Volume Usages    volume_list=${volumes}    volume_device_remaps=${DEVICE_REMAPS}
    ${overused_volumes}=    RW.AWS.CloudWatch.Filter Metric Dict    ${volume_device_usages}    Less Than    ${OVERUSED_VOLUME_THRESHOLD}
    ${report}=    RW.AWS.EC2.Run Resourcing Check    region_name=${REGION}    resource_dict=${overused_volumes}    resource_name=Over-utilized EBS volumes    check_title=EBS Volume Over Utilization Check
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
    RW.Core.Import User Variable    TAGS_LIST
    ...    type=string
    ...    description=A json blob representing the tags to include in queries.
    ...    pattern=\w*
    ...    example='{"mytag":"myvalue"}'
    ...    default='{}'
    RW.Core.Import User Variable    DEVICE_REMAPS
    ...    type=string
    ...    description=A json blob used to remap the EBS device names on an EC2 instance to the internal linux filesystem device names. Correct remapping is required for volume tasks to work.
    ...    pattern=\w*
    ...    example='{"/dev/sdf":"xvdf"}'
    ...    default='{}'
    RW.Core.Import User Variable
    ...    SECONDS_IN_PAST
    ...    type=string
    ...    description=The number of seconds of history to consider for SLI values. Depends on provider's sampling rate. Consider 600 as a starter.
    ...    pattern="^[0-9]*$"
    ...    example=600
    ...    default=600
    RW.Core.Import User Variable
    ...    OVERUSED_CPU_THRESHOLD
    ...    type=string
    ...    description=The average metric number at which a instance CPU is considered over-utilized. For CloudWatch 0-100 is 0-100%.
    ...    pattern="^[0-9]*$"
    ...    example=80
    ...    default=80
    RW.Core.Import User Variable
    ...    UNDERUSED_CPU_THRESHOLD
    ...    type=string
    ...    description=The average metric number at which a instance CPU is considered under-utilized. For CloudWatch 0-100 is 0-100%.
    ...    pattern="^[0-9]*$"
    ...    example=3
    ...    default=3
    RW.Core.Import User Variable
    ...    OVERUSED_VOLUME_THRESHOLD
    ...    type=string
    ...    description=The average % disk usage metric for an EBS volume to be considered over-utilized.
    ...    pattern="^[0-9]*$"
    ...    example=80
    ...    default=80
    RW.Core.Import User Variable
    ...    UNDERUSED_VOLUME_THRESHOLD
    ...    type=string
    ...    description=The average % disk usage metric for an EBS volume to be considered under-utilized.
    ...    pattern="^[0-9]*$"
    ...    example=5
    ...    default=5
    Set Suite Variable    ${AWS_ACCESS_KEY_ID}    ${AWS_ACCESS_KEY_ID}
    Set Suite Variable    ${AWS_SECRET_ACCESS_KEY}    ${AWS_SECRET_ACCESS_KEY}
    Set Suite Variable    ${AWS_ROLE_ASSUME_ARN}    ${AWS_ROLE_ASSUME_ARN}
    Set Suite Variable    ${AUTH_MODE}    ${AUTH_MODE}
    Set Suite Variable    ${REGION}    ${REGION}
    Set Suite Variable    ${SECONDS_IN_PAST}    ${SECONDS_IN_PAST}
    Set Suite Variable    ${TAGS_LIST}    ${TAGS_LIST}
    Set Suite Variable    ${DEVICE_REMAPS}    ${DEVICE_REMAPS}
    Set Suite Variable    ${OVERUSED_CPU_THRESHOLD}    ${OVERUSED_CPU_THRESHOLD}
    Set Suite Variable    ${UNDERUSED_CPU_THRESHOLD}    ${UNDERUSED_CPU_THRESHOLD}
    Set Suite Variable    ${OVERUSED_VOLUME_THRESHOLD}    ${OVERUSED_VOLUME_THRESHOLD}
    Set Suite Variable    ${UNDERUSED_VOLUME_THRESHOLD}    ${UNDERUSED_VOLUME_THRESHOLD}
