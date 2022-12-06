#  monitor billing
#  Get billing info for report *

"""
AWS Billing keyword library

Scope: Global
"""
import boto3, re, time, json
from benedict import benedict
from datetime import datetime,timedelta, date
from dataclasses import dataclass
from typing import Union, Optional
from RW.AWS.mixins.AWSAuthenticationMixin import AWSAuthenticationMixin
from RW.Utils.Check import Check


class Billing(AWSAuthenticationMixin):
    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def get_cost_and_usage(self,
        granularity="MONTHLY",
        start=(date.today()-timedelta(days=30)),
        tag_key:str="",
        tag_value:str="",
        end=date.today(),
        days_in_past:int=0,
        metrics=["AmortizedCost", "BlendedCost", "NetAmortizedCost", "NetUnblendedCost", "NormalizedUsageAmount", "UnblendedCost", "UsageQuantity"]
    ):
        """
        For more information on which metrics to include or use in reports, refer to https://docs.aws.amazon.com/cost-management/latest/userguide/ce-advanced.html
        """
        granularity = granularity.upper()
        if days_in_past:
            start=(date.today()-timedelta(days=days_in_past))
        costs = None
        if granularity not in ["DAILY","MONTHLY","HOURLY"]:
            raise ValueError(f"granularity {granularity} must be one of: DAILY, MONTHLY, HOURLY")
        if tag_key and tag_value:
            tag_filter = {
                "Tags":{           
                    "Key": f"{tag_key}",
                    "Values": [
                        f"{tag_value}",
                    ],
                    "MatchOptions": [
                        "EQUALS",
                    ]
                }
            }
        else:
            tag_filter = {} # if falsey default to boto3 empty param type
        client = self.get_client("ce")
        if tag_filter:
            rsp = client.get_cost_and_usage(
                TimePeriod={
                    "Start": f"{start}",
                    "End": f"{end}",
                },
                Filter=tag_filter,
                Granularity=granularity,
                Metrics=metrics,
            )
        else:
            rsp = client.get_cost_and_usage(
                TimePeriod={
                    "Start": f"{start}",
                    "End": f"{end}",
                },
                Granularity=granularity,
                Metrics=metrics,
            )
        costs = rsp
        return costs

    def get_costs_per_tag(self, granularity: str, tag_dict):
        granularity = granularity.upper()
        if tag_dict:
            tag_dict = json.loads(tag_dict) # TODO: review this string->dict approach
        costs_by_tag = {}
        for tag_key, tag_value in tag_dict.items():
            costs_by_tag[f"{tag_key}:{tag_value}"] = self.get_cost_and_usage(granularity=granularity, tag_key=tag_key, tag_value=tag_value)
        return costs_by_tag

    def get_cost_metric_from_results(self, costs, cost_metric):
        return costs["ResultsByTime"][-1]["Total"][cost_metric]["Amount"]
    
    def run_report_on_tagged_costs(self, tagged_costs):
        checks = []
        checks.append(str(Check(
            indented=False,
            title="AWS CostExplorer Billing Report\n",
        )))
        for tag, costs_breakdown in tagged_costs.items():
            recent_billing_period = costs_breakdown["ResultsByTime"][-1]
            end = recent_billing_period["TimePeriod"]["End"]
            start = recent_billing_period["TimePeriod"]["Start"]
            totals = recent_billing_period["Total"]
            cost_listing = []
            for total_type, total in totals.items():
                cost_listing.append(f"\t{total_type} Amount: {total['Amount']} Unit: {total['Unit']}")
            cost_listing = "\n".join(cost_listing)
            checks.append(str(Check(
                title=f"Cost for resources tagged with: {tag} from {start} to {end}",
                description=cost_listing,
                indented=False,
            )))
        return "\n".join(checks)
