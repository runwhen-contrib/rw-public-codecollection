"""
AWS EC2 keyword library

Scope: Global
"""
import boto3, datetime, re, time, json
from enum import Enum
from dataclasses import dataclass
from typing import Union, Optional
from benedict import benedict
from RW.AWS.mixins.AWSAuthenticationMixin import AWSAuthenticationMixin
from RW.Utils.Check import Check


class EC2(AWSAuthenticationMixin):
    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    class ConfigOptions(Enum):
        YES = "Yes"
        NO = "No"

    def get_ec2_instances(self, tag_filter={}, limit: int = 500):
        """ """
        instances = []
        if tag_filter:
            if isinstance(tag_filter, str):
                tag_filter = json.loads(tag_filter)
            tag_filter = [
                {
                    "Name": f"tag:{key}",
                    "Values": [
                        f"{value}",
                    ],
                }
                for key, value in tag_filter.items()
            ]
        else:
            tag_filter = []  # if falsey default to boto3 empty param type
        client = self.get_client("ec2")
        rsp = client.describe_instances(
            Filters=tag_filter,
            MaxResults=limit,
        )
        reservations = rsp["Reservations"]
        for res in reservations:
            instances = instances + res["Instances"]
        while "NextToken" in rsp:
            rsp = client.describe_instances(
                Filters=tag_filter,
                MaxResults=limit,
                NextToken=rsp["NextToken"],
            )
            reservations = rsp["Reservations"]
            for res in reservations:
                instances = instances + res["Instances"]
        return instances
    
    def get_ec2_instance_ids(self, instance_list=None, tag_filter={}, limit: int = 500):
        instance_ids = []
        if not instance_list:
            instance_list = self.get_ec2_instances(tag_filter=tag_filter, limit=limit)
        instance_ids = [instance["InstanceId"] for instance in instance_list]
        return instance_ids

    def get_vpcs(self, tag_filter={}, limit: int = 500) -> []:
        vpcs = []
        if tag_filter:
            tag_filter = [
                {
                    "Name": f"tag:{key}",
                    "Values": [
                        f"{value}",
                    ],
                }
                for key, value in tag_filter.items()
            ]
        else:
            tag_filter = []  # if falsey default to boto3 empty param type
        client = self.get_client("ec2")
        rsp = client.describe_vpcs(
            Filters=tag_filter,
            MaxResults=limit,
        )
        vpcs = rsp["Vpcs"]
        while "NextToken" in rsp:
            rsp = client.describe_vpcs(
                Filters=tag_filter,
                MaxResults=limit,
                NextToken=rsp["NextToken"],
            )
            vpcs = vpcs + rsp["Vpcs"]
        return vpcs

    def get_subnets(self, tag_filter={}, limit: int = 500) -> []:
        subnets = []
        if tag_filter:
            tag_filter = [
                {
                    "Name": f"tag:{key}",
                    "Values": [
                        f"{value}",
                    ],
                }
                for key, value in tag_filter.items()
            ]
        else:
            tag_filter = []  # if falsey default to boto3 empty param type
        client = self.get_client("ec2")
        rsp = client.describe_subnets(
            Filters=tag_filter,
            MaxResults=limit,
        )
        subnets = rsp["Subnets"]
        while "NextToken" in rsp:
            rsp = client.describe_subnets(
                Filters=tag_filter,
                MaxResults=limit,
                NextToken=rsp["NextToken"],
            )
            subnets = subnets + rsp["Subnets"]
        return subnets
    
    def get_route_tables(self, tag_filter={}, limit: int = 100) -> []:
        route_tables = []
        if tag_filter:
            tag_filter = [
                {
                    "Name": f"tag:{key}",
                    "Values": [
                        f"{value}",
                    ],
                }
                for key, value in tag_filter.items()
            ]
        else:
            tag_filter = []  # if falsey default to boto3 empty param type
        client = self.get_client("ec2")
        rsp = client.describe_route_tables(
            Filters=tag_filter,
            MaxResults=limit,
        )
        route_tables = rsp["RouteTables"]
        while "NextToken" in rsp:
            rsp = client.describe_route_tables(
                Filters=tag_filter,
                MaxResults=limit,
                NextToken=rsp["NextToken"],
            )
            route_tables = route_tables + rsp["RouteTables"]
        return route_tables

    def get_volumes(self, tag_filter={}, limit: int = 100) -> []:
        volumes = []
        if tag_filter:
            tag_filter = [
                {
                    "Name": f"tag:{key}",
                    "Values": [
                        f"{value}",
                    ],
                }
                for key, value in tag_filter.items()
            ]
        else:
            tag_filter = []  # if falsey default to boto3 empty param type
        client = self.get_client("ec2")
        rsp = client.describe_volumes(
            Filters=tag_filter,
            MaxResults=limit,
        )
        volumes = rsp["Volumes"]
        while "NextToken" in rsp:
            rsp = client.describe_volumes(
                Filters=tag_filter,
                MaxResults=limit,
                NextToken=rsp["NextToken"],
            )
            volumes = volumes + rsp["Volumes"]
        return volumes
    
    def get_volumes_with_no_attachments(self, volume_list:list=[], tag_filter={}, limit: int = 100) -> []:
        not_attached = []
        if not volume_list:
            volume_list = self.get_volumes(tag_filter=tag_filter, limit=limit)
        for volume in volume_list:
            if "Attachments" not in volume or not volume["Attachments"]:
                not_attached.append(volume)
        return not_attached

    def get_volume_ids(self, volume_list:list=[], tag_filter={}, limit: int = 100) -> []:
        volume_ids = []
        if not volume_list:
            volume_list = self.get_volumes(tag_filter=tag_filter, limit=limit)
        for volume in volume_list:
            volume_ids.append(volume["VolumeId"])
        return volume_ids

    def get_block_devices_from_instances(self, instance_list: list = [], tag_filter={}, limit: int = 500) -> []:
        if not instance_list:
            instance_list = self.get_ec2_instances(tag_filter, limit)
        block_devices = []
        for instance in instance_list:
            if "BlockDeviceMappings" in instance:
                block_devices = block_devices + instance["BlockDeviceMappings"]
        return block_devices

    def get_untagged_instances(self, instance_list: list = [], tag_filter={}, limit: int = 500) -> []:
        if not instance_list:
            instance_list = self.get_ec2_instances(tag_filter, limit)
        untagged_instances = [instance for instance in instance_list if "Tags" not in instance or not instance["Tags"]]
        return untagged_instances

    def get_vpcs_ids_from_instances(self, instance_list: list = [], tag_filter={}, limit: int = 500) -> []:
        if not instance_list:
            instance_list = self.get_ec2_instances(tag_filter, limit)
        vpc_ids = []
        for instance in instance_list:
            if "VpcId" in instance and instance["VpcId"] not in vpc_ids:
                vpc_ids.append(instance["VpcId"])
            if "NetworkInterfaces" in instance:
                for ni in instance["NetworkInterfaces"]:
                    if "VpcId" in ni and ni["VpcId"] not in vpc_ids:
                        vpc_ids.append(ni["VpcId"])
        return vpc_ids

    def get_subnet_ids_from_instances(self, instance_list: list = [], tag_filter={}, limit: int = 500) -> []:
        if not instance_list:
            instance_list = self.get_ec2_instances(tag_filter, limit)
        subnet_ids = []
        for instance in instance_list:
            if "SubnetId" in instance and instance["SubnetId"] not in subnet_ids:
                subnet_ids.append(instance["SubnetId"])
            if "NetworkInterfaces" in instance:
                for ni in instance["NetworkInterfaces"]:
                    if "SubnetId" in ni and ni["SubnetId"] not in subnet_ids:
                        subnet_ids.append(ni["SubnetId"])
        return subnet_ids
    
    def find_open_routes(self, route_table_list=[], tag_filter={}, limit: int = 100) -> []:
        open_routes = []
        if not route_table_list:
            route_table_list = self.get_route_tables(tag_filter=tag_filter, limit=limit)
        for route_table in route_table_list:
            if "Routes" in route_table:
                routes = route_table["Routes"]
                for route in routes:
                    cidr_block = route["DestinationCidrBlock"]
                    if cidr_block == "0.0.0.0/0":
                        open_routes.append(route_table)
        return open_routes

    # Helpers
    # TODO: move these to dedicated helper keyword
    def filter_dicts_with_list(self, dict_list, dict_key, value_list):
        filtered = [data_dict for data_dict in dict_list if data_dict[dict_key] in value_list]
        return filtered

    def get_intersections(self, source_list: dict, source_key_list: list, target_key_list: list, target: dict) -> []:
        intersections = []
        for source in source_list:
            if self.check_keypath_intersection(source, source_key_list, target_key_list, target):
                intersections.append(source)
        return intersections

    def check_keypath_intersection(self, source: dict, source_key_list: list, target_key_list: list, target: dict) -> bool:
        source = benedict(source)
        target = benedict(target)
        source_key_path = ".".join(source_key_list)
        target_key_path = ".".join(target_key_list)
        if source_key_path in source and target_key_path in target and source[source_key_path] == target[target_key_path]:
            return True
        else:
            return False
    
    def get_list_of_values_from_dicts(self, dict_objects, key) -> []:
        value_list = []
        for dict_object in dict_objects:
            if key in dict_object:
                value_list.append(dict_object[key])
        return value_list
    
    # checks for creating reports
    #
    def run_untagged_ec2_checks(self, region_name, untagged_instance_list):
        total_untagged_instances = len(untagged_instance_list)
        checks = []
        checks.append(str(Check(
            indented=False,
            title="AWS EC2 Untagged Instances Check",
        )))
        checks.append(str(Check(
            title="Passed untagged instance check:",
            symbol=bool(total_untagged_instances == 0),
        )))
        checks.append(str(Check(
            title=f"Total untagged EC2 instances found in region {region_name}:",
            value=f"{total_untagged_instances}",
        )))
        if untagged_instance_list:
            checks.append(str(Check(
                title=f"EC2 untagged instance list:",
                value=f"{untagged_instance_list}",
            )))
        return "\n".join(checks)

    def run_open_routes_check(self, region_name, open_instances):
        total_open_instances = len(open_instances)
        checks = []
        checks.append(str(Check(
            indented=False,
            title="AWS EC2 Instances With Open Routes Check",
        )))
        checks.append(str(Check(
            title="Passed open instance check:",
            symbol=bool(total_open_instances == 0),
        )))
        checks.append(str(Check(
            title=f"Total EC2 instances open routes found in region {region_name}:",
            value=f"{total_open_instances}",
        )))
        if open_instances:
            checks.append(str(Check(
                title=f"EC2 instances with open route list: {open_instances}",
                value=f"{open_instances}",
            )))
        return "\n".join(checks)

    def run_dangling_volumes_check(self, region_name, dangling_volumes:list):
        total_dangling_volumes = len(dangling_volumes)
        checks = []
        checks.append(str(Check(
            indented=False,
            title="AWS Dangling Volume Check",
        )))
        checks.append(str(Check(
            title="Passed dangling volumes check:",
            symbol=bool(total_dangling_volumes == 0),
        )))
        checks.append(str(Check(
            title=f"Total dangling volumes found in region {region_name}:",
            value=f"{total_dangling_volumes}",
        )))
        if dangling_volumes:
            checks.append(str(Check(
                title=f"Dangling volume list: {dangling_volumes}",
                value=f"{dangling_volumes}",
            )))
        return "\n".join(checks)

    def run_resourcing_check(self, region_name, resource_dict:dict, resource_name, check_title):
        total_resources_detected = len(resource_dict.keys())
        checks = []
        checks.append(str(Check(
            indented=False,
            title=f"{check_title}",
        )))
        checks.append(str(Check(
            title=f"Passed {resource_name} check:",
            symbol=bool(total_resources_detected == 0),
        )))
        checks.append(str(Check(
            title=f"Total {resource_name} found in region {region_name}:",
            value=f"{total_resources_detected}",
        )))
        if total_resources_detected > 0:
            checks.append(str(Check(
                title=f"{resource_name} list:",
                value=f"{list(resource_dict.keys())}",
            )))
        return "\n".join(checks)