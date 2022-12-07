"""
AWS S3 keyword library

Scope: Global
"""
import boto3, re, time, json
from datetime import datetime,timedelta, date
from dataclasses import dataclass
from typing import Union, Optional
from RW.AWS.mixins.AWSAuthenticationMixin import AWSAuthenticationMixin
from RW.Utils.Check import Check


class S3(AWSAuthenticationMixin):
    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def get_buckets(self) -> []:
        buckets = []
        client = self.get_client("s3")
        rsp = client.list_buckets()
        if "Buckets" in rsp:
            buckets = buckets + rsp["Buckets"]
        return buckets
    
    def get_bucket_objects(self, bucket_name) -> []:
        objects = []
        client = self.get_client("s3")
        rsp = client.list_objects(Bucket=bucket_name)
        if "Contents" in rsp:
            objects = rsp["Contents"]
        return objects


    def get_bucket_last_access_time(self, bucket_name):
        last_access_time = None
        objects = self.get_bucket_objects(bucket_name)
        if objects:
            access_times = [obj["LastModified"] for obj in objects if "LastModified" in obj]
            access_times = sorted(access_times, key=lambda access_time: access_time, reverse=True)
            last_access_time = access_times[0]
        return last_access_time
    
    def get_last_access_time_of_buckets(self, bucket_list:list=[]) -> []:
        last_access_times = {}
        if not bucket_list:
            bucket_list = self.get_buckets()
        for bucket in bucket_list:
            last_access_time = self.get_bucket_last_access_time(bucket["Name"])
            last_access_times[bucket["Name"]] = last_access_time
        return last_access_times
    
    def get_stale_buckets(self, access_times=None, days_stale_threshold=30):
        stale = {}
        oldest_allowed = datetime.now() - timedelta(days=days_stale_threshold)
        if not access_times:
            access_times = self.get_last_access_time_of_buckets()
        for bucket, access_time in access_times.items():
            if isinstance(access_time, datetime):
                access_time = access_time.replace(tzinfo=None) # make tz naive
                if access_time < oldest_allowed:
                    stale[bucket] = access_time
            else:
                stale[bucket] = None
        return stale
    
    def run_s3_checks(self, region_name, days_stale_threshold=90):
        access_times = self.get_last_access_time_of_buckets()
        stale_times = self.get_stale_buckets(access_times=access_times, days_stale_threshold=days_stale_threshold)
        bucket_list = access_times.keys()
        total_buckets = len(bucket_list)
        total_stale_buckets = len(stale_times.keys())
        checks = []
        checks.append(str(Check(
            indented=False,
            title="AWS S3 Bucket Checks",
        )))
        checks.append(str(Check(
            title=f"Total S3 Buckets scanned in region {region_name}:",
            value=f"{total_buckets}",
        )))
        checks.append(str(Check(
            title=f"Stale Buckets Detected in region {region_name}:",
            value=f"{total_stale_buckets}",
        )))
        if stale_times:
            checks.append(str(Check(
                title=f"Stale Bucket List:",
                value=f"{stale_times}",
            )))
        return "\n".join(checks)