
"""
AWS CloudFormation keyword library

Scope: Global
"""
import boto3, datetime, re, time, json
from dataclasses import dataclass
from typing import Union, Optional
from RW.AWS.mixins.AWSAuthenticationMixin import AWSAuthenticationMixin


class CloudFormation(AWSAuthenticationMixin):
    """
    AWS CloudFormation keyword library for integrating with AWS CloudFormation.
    """

    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def get_stack_events(self, stack_name):
        """
        Gets a list of stack events under a name as json.

        Examples:
        | RW.AWS.CloudFormation.Get Stack Events  |     MyStackName     |

        Return Value:
        |   stack_event_info: json  |
        """
        client = self.get_client("cloudformation")
        rsp = client.describe_stack_events(StackName=stack_name)
        events = rsp["StackEvents"]
        while "NextToken" in rsp:
            rsp = client.describe_stack_events(NextToken=rsp["NextToken"])
            events.extend(rsp["StackEvents"])
        return events
    
    def get_all_stack_events(self, event_status="", seconds_in_past=None):
        """
        Gets all stack events across all stacks and filters them.

        Examples:
        | RW.AWS.CloudFormation.Get All Stack Events  |     CREATE_COMPLETE     |      600  |

        Return Value:
        |   stack_event_info: json  |
        """
        stacks = [s["StackName"] for s in self.get_stack_summaries()]
        events = []
        for s in stacks:
            stack_events = self.get_stack_events(s)
            if event_status:
                stack_events = self.filter_stack_events_by_status(stack_events, event_status)
            if seconds_in_past:
                stack_events = self.filter_stack_events_by_time(stack_events, seconds_in_past)
            events.append(stack_events)
        return events

    def get_stack_summaries(self):
        """
        Get a list of summaries for each stack.

        Examples:
        | RW.AWS.CloudFormation.Get Stack Summaries  |

        Return Value:
        |   stack_summaries: json  |
        """
        client = self.get_client("cloudformation")
        rsp = client.list_stacks()
        summaries = rsp["StackSummaries"]
        while "NextToken" in rsp:
            rsp = client.list_stacks(NextToken=rsp["NextToken"])
            summaries.extend(rsp["StackSummaries"])
        return summaries
    
    def filter_stack_events(self, events, event_status):
        """
        *DEPRECATED*
        Filters out stack events which do not match the status.
        """
        filtered_events = [e for e in events if e["ResourceStatus"] == event_status]
        return filtered_events

    def filter_stack_events_by_status(self, events, event_status):
        """
        Filters out stack events which do not match the status.
        """
        filtered_events = [e for e in events if e["ResourceStatus"] == event_status]
        return filtered_events

    def filter_stack_events_by_time(self, events, seconds_in_past):
        """
        Filters out stack events older than seconds back in the past provided.
        """
        utc_today = datetime.datetime.utcnow()
        utc_past = utc_today - datetime.timedelta(seconds=int(seconds_in_past))
        filtered_events = [e for e in events if e["Timestamp"].replace(tzinfo=None) >= utc_past]
        return filtered_events

    def json_stringify(self, response_data):
        """
        Helper method for platform compatibility. Checks data is safe to load as json.
        If this method encounters a type it cannot understand, it change it to a string.
        """
        response_json = json.dumps(response_data, default=str)
        response_data = json.loads(response_json)
        return response_data

    
