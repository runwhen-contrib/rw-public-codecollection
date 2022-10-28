*** Settings ***
Library           RW.AWS.EC2
Library           RW.AWS.CloudWatch
Library           RW.AWS.S3
Library           RW.AWS.Billing
Suite Setup       Suite Initialization

*** Variables ***
${SECONDS_IN_PAST}    3600

*** Tasks ***
Get All Publically Exposed EC2 Instances
    ${rsp}=    RW.AWS.EC2.Authenticate
    ...    ${AWS_ACCESS_KEY_ID}
    ...    ${AWS_SECRET_ACCESS_KEY}
    ...    ${AWS_REGION}
    ...    role_arn=${AWS_ROLE_ASSUME_ARN}
    ...    auth_mode=Role
    ${route_tables}=    RW.AWS.EC2.Get Route Tables
    ${open_routes}=    RW.AWS.EC2.Find Open Routes    ${route_tables}
    ${instances}=    RW.AWS.EC2.Get Ec2 Instances
    ${vpc_ids}=    RW.AWS.EC2.Get Vpcs Ids From Instances    ${instances}
    ${open_vpc_ids}=    Evaluate    [open_route["VpcId"] for open_route in ${open_routes}]
    ${open_instances}=    RW.AWS.EC2.Filter Dicts With List    ${instances}    VpcId    ${open_vpc_ids}
    ${open_instance_ids}=    RW.AWS.EC2.Get Ec2 Instance Ids    instance_list=${open_instances}
    Log    ${open_instance_ids}

Get All Untagged EC2 Instances
    ${rsp}=    RW.AWS.EC2.Authenticate
    ...    ${AWS_ACCESS_KEY_ID}
    ...    ${AWS_SECRET_ACCESS_KEY}
    ...    ${AWS_REGION}
    ...    role_arn=${AWS_ROLE_ASSUME_ARN}
    ...    auth_mode=Role
    ${instances}=    RW.AWS.EC2.Get Untagged Instances
    ${instance_ids}=    RW.AWS.EC2.Get Ec2 Instance Ids    instance_list=${instances}
    ${report}=    RW.AWS.EC2.Run Untagged Ec2 Checks    ${AWS_REGION}    ${instance_ids}

Get All EC2 Instances With Zero Activity
    ${rsp}=    RW.AWS.EC2.Authenticate
    ...    ${AWS_ACCESS_KEY_ID}
    ...    ${AWS_SECRET_ACCESS_KEY}
    ...    ${AWS_REGION}
    ...    role_arn=${AWS_ROLE_ASSUME_ARN}
    ...    auth_mode=Role
    ${instances}=    RW.AWS.EC2.Get Ec2 Instances
    ${instance_ids}=    RW.AWS.EC2.Get Ec2 Instance Ids    instance_list=${instances}
    ${rsp}=    RW.AWS.CloudWatch.Authenticate
    ...    ${AWS_ACCESS_KEY_ID}
    ...    ${AWS_SECRET_ACCESS_KEY}
    ...    ${AWS_REGION}
    ...    role_arn=${AWS_ROLE_ASSUME_ARN}
    ...    auth_mode=Role
    ${rsp}=    RW.AWS.CloudWatch.Multi Metric Query    ${AWS_TEMPLATED_METRIC_QUERY}    ${SECONDS_IN_PAST}
    ...    aws_ids=${instance_ids}
    ${underused}=    RW.AWS.CloudWatch.Filter Metric Dict    ${rsp}    Greater Than    5
    ${count}=    Evaluate    len($underused)

Get Stale Buckets
    ${rsp}=    RW.AWS.S3.Authenticate
    ...    ${AWS_ACCESS_KEY_ID}
    ...    ${AWS_SECRET_ACCESS_KEY}
    ...    ${AWS_REGION}
    ...    role_arn=${AWS_ROLE_ASSUME_ARN}
    ...    auth_mode=Role
    ${access_times}=    RW.AWS.S3.Get Stale Buckets    days_stale_threshold=1

Create Report For Buckets
    ${rsp}=    RW.AWS.S3.Authenticate
    ...    ${AWS_ACCESS_KEY_ID}
    ...    ${AWS_SECRET_ACCESS_KEY}
    ...    ${AWS_REGION}
    ...    role_arn=${AWS_ROLE_ASSUME_ARN}
    ...    auth_mode=Role
    ${report}=    RW.AWS.S3.Run S3 Checks    region_name=${AWS_REGION}    days_stale_threshold=0

Create Security Report
    ${rsp}=    RW.AWS.EC2.Authenticate
    ...    ${AWS_ACCESS_KEY_ID}
    ...    ${AWS_SECRET_ACCESS_KEY}
    ...    ${AWS_REGION}
    ...    role_arn=${AWS_ROLE_ASSUME_ARN}
    ...    auth_mode=Role
    ${rsp}=    RW.AWS.CloudWatch.Authenticate
    ...    ${AWS_ACCESS_KEY_ID}
    ...    ${AWS_SECRET_ACCESS_KEY}
    ...    ${AWS_REGION}
    ...    role_arn=${AWS_ROLE_ASSUME_ARN}
    ...    auth_mode=Role
    ${TAG_FILTER}    Evaluate    '''{"group":"metrics"}'''
    ${DEVICE_NAME_REMAPS}    Evaluate    '''{"/dev/sdf":"xvdf"}'''
    ${instances}=    RW.AWS.EC2.Get Ec2 Instances    tag_filter=${TAG_FILTER}
    ${instance_ids}=    RW.AWS.EC2.Get Ec2 Instance Ids    instance_list=${instances}
    ${instance_block_devices}=    RW.AWS.EC2.Get Block Devices From Instances    ${instances}
    ${all_volumes}=    RW.AWS.EC2.Get Volumes    #tag_filter=${TAG_FILTER}
    ${dangling_volumes}=    RW.AWS.EC2.Get Volumes With No Attachments    volume_list=${all_volumes}
    ${dangling_volume_ids}=    RW.AWS.EC2.Get Volume Ids    volume_list=${dangling_volumes}
    ${volume_device_usages}=    RW.AWS.CloudWatch.Get Volume Usages    volume_list=${all_volumes}    volume_device_remaps=${DEVICE_NAME_REMAPS}
    ${overused_volumes}=    RW.AWS.CloudWatch.Filter Metric Dict    ${volume_device_usages}    Less Than    80
    ${underused_volumes}=    RW.AWS.CloudWatch.Filter Metric Dict    ${volume_device_usages}    Greater Than    5
    ${instance_cpu_utils}=    RW.AWS.CloudWatch.Multi Metric Query    SELECT AVG(CPUUtilization) FROM "AWS/EC2" WHERE InstanceId = '{aws_id}'    ${SECONDS_IN_PAST}
    ...    aws_ids=${instance_ids}
    ${overrused_cpu}=    RW.AWS.CloudWatch.Filter Metric Dict    ${instance_cpu_utils}    Less Than    80
    ${underused_cpus}=    RW.AWS.CloudWatch.Filter Metric Dict    ${instance_cpu_utils}    Greater Than    5
    ${report}=    RW.AWS.EC2.Run Resourcing Check    region_name=${AWS_REGION}    resource_dict=${overused_volumes}    resource_name=Over-utilized EBS volumes    check_title=EBS Volume Over Utilization Check
    ${report}=    RW.AWS.EC2.Run Resourcing Check    region_name=${AWS_REGION}    resource_dict=${underused_volumes}    resource_name=Under-utilized EBS volumes    check_title=EBS Volume Over Utilization Check
    ${report}=    RW.AWS.EC2.Run Resourcing Check    region_name=${AWS_REGION}    resource_dict=${overrused_cpu}    resource_name=Over-utilized EC2 CPU    check_title=EC2 CPU Over-utilization Check
    ${report}=    RW.AWS.EC2.Run Resourcing Check    region_name=${AWS_REGION}    resource_dict=${underused_cpus}    resource_name=Under-utilized EC2 CPU    check_title=EC2 CPU Over-utilization Check

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
    Set Suite Variable    ${AWS_TEMPLATED_METRIC_QUERY}    %{AWS_TEMPLATED_METRIC_QUERY}
    Set Suite Variable    ${AWS_LOG_GROUP}    %{AWS_LOG_GROUP}
