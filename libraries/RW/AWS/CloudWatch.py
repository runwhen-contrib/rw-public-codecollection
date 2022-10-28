"""
AWS CloudWatch keyword library

Scope: Global
"""
import boto3, re, time, json, urllib
from datetime import datetime, timedelta
from urllib.parse import quote
from dataclasses import dataclass
from typing import Union, Optional
from RW.AWS.mixins.AWSAuthenticationMixin import AWSAuthenticationMixin


class CloudWatch(AWSAuthenticationMixin):
    """
    CloudWatch is a keyword library for integrating with AWS CloudWatch.
    """

    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def metric_query(self, metric_query, seconds_in_past):
        """
        Used to fetch a metric value from the CloudWatch Metric Insights API endpoint.

        Examples:
        |   RW.AWS.CloudWatch.Metric Query  |   ${METRIC_QUERY}     |   ${MAX_METRIC_HISTORY}   |
        Return Value:
        |   metric_result_set: json     |
        """
        seconds_in_past = int(seconds_in_past)
        if not self.aws_access_key_id or not self.aws_secret_access_key:
            raise Exception(
                "The session credentials aws_access_key_id and aws_secret_access_key must be set before executing commands"
            )
        client = self.get_client("cloudwatch")
        # Consider a seconds_in_past of 600 or more
        utc_today = datetime.utcnow()
        utc_past = (
            utc_today - timedelta(seconds=int(seconds_in_past))
        ).strftime("%Y-%m-%dT%H:%M:%SZ")
        utc_today = utc_today.strftime("%Y-%m-%dT%H:%M:%SZ")
        rsp = client.get_metric_data(
            MetricDataQueries=[
                {
                    "Id": f"runwhenMetric",
                    "ReturnData": True,
                    "Expression": metric_query,
                    "Period": int(seconds_in_past),
                },
            ],
            StartTime=utc_past,
            EndTime=utc_today,
            MaxDatapoints=10,
            ScanBy="TimestampDescending",
        )
        # if rsp["Message"] == "InternalError":
        #     raise Exception(f"CloudWatch response contained message:{rsp['Message']} with code: {rsp['InternalError']}")
        return rsp
    
    def templated_metric_query(self, metric_query, seconds_in_past, **kwargs):
        metric_query = metric_query.format(**kwargs)
        return self.metric_query(metric_query, seconds_in_past)
    
    def multi_metric_query(self, metric_query, seconds_in_past, aws_ids):
        metrics = {}
        for aws_id in aws_ids:
            try:
                metric = self.templated_metric_query(metric_query, seconds_in_past, aws_id=aws_id)
                metric = self.most_recent_metric_from_results(metric)
            except:
                metric = None
            if metric:
                metrics[aws_id] = metric
        return metrics
    
    def get_volume_usages(self, volume_list: list, volume_device_remaps={}, seconds_in_past=10800) -> {}:
        if volume_device_remaps and isinstance(volume_device_remaps, str):
            volume_device_remaps = json.loads(volume_device_remaps)
        volume_usages = {}
        for volume in volume_list:
            volume_usage = None
            if "Attachments" in volume and volume["Attachments"]:
                for attachment in volume["Attachments"]:
                    ec2_id = attachment["InstanceId"]
                    volume_id = volume['VolumeId']
                    device = attachment["Device"]
                    # internal instance device names could differ from the EC2 API values so we allow user controlled overrides
                    if device in volume_device_remaps.keys():
                        device = volume_device_remaps[device]
                    usage_query = f"SELECT MAX(disk_used_percent) FROM CWAgent WHERE InstanceId = '{ec2_id}' AND device = '{device}'"
                    # although we generally want to raise up to robot runtime, we make an exception here and catch it
                    # because attachments may no longer be valid/exist as we query them, thus resulting in no results / error
                    # but we want to attempt every attachment
                    try:
                        rsp = self.metric_query(usage_query, seconds_in_past)
                        volume_usage = self.most_recent_metric_from_results(rsp)
                    except:
                        volume_usage = None
                    if volume_usage and f"{volume_id}:{device}" not in volume_usages:
                        volume_usages[f"{volume_id}:{device}"] = volume_usage
                        break
        return volume_usages

    def filter_metric_dict(self, metric_dict, method, threshold):
        method = method.title()
        if method not in ["Less Than","Greater Than"]:
            raise ValueError(f"method {method} not one of: Less Than, Greater Than")
        threshold = float(threshold)
        filtered = {}
        for key,value in metric_dict.items():
            if method == "Less Than" and value >= threshold:
                filtered[key] = value
            elif method == "Greater Than" and value <= threshold:
                filtered[key] = value
        return filtered

    def transform_metric_dict(self, method:str, metric_dict: dict):
        column = metric_dict.values()
        if method == "Max":
            return max(column)
        elif method == "Average":
            return sum(column) / len(column)
        elif method == "Minimum":
            return min(column)
        elif method == "Sum":
            return sum(column)

    def most_recent_metric_from_results(
        self, cloudwatch_metric_results, default_first_index=0
    ):
        """
        Helper method which accesses most recent metric (unless determined otherwise by query)
        """
        if not cloudwatch_metric_results["MetricDataResults"]:
            raise Exception(
                f"CloudWatch response results empty:{cloudwatch_metric_results['MetricDataResults']}"
            )
        elif (
            not cloudwatch_metric_results["MetricDataResults"][default_first_index][
                "Timestamps"
            ]
            or not cloudwatch_metric_results["MetricDataResults"][default_first_index][
                "Values"
            ]
        ):
            raise Exception(
                f"CloudWatch response malformed:{cloudwatch_metric_results['Message']}"
            )
        metric_value = cloudwatch_metric_results["MetricDataResults"][
            default_first_index
        ]["Values"][default_first_index]
        return metric_value

    def largest_metric_from_results(
        self, cloudwatch_metric_results, default_first_index=0
    ):
        """
        Helper method which largest metric value in the set.
        """
        if not cloudwatch_metric_results["MetricDataResults"]:
            raise Exception(
                f"CloudWatch response results empty:{cloudwatch_metric_results['MetricDataResults']}"
            )
        elif (
            not cloudwatch_metric_results["MetricDataResults"][default_first_index][
                "Timestamps"
            ]
            or not cloudwatch_metric_results["MetricDataResults"][default_first_index][
                "Values"
            ]
        ):
            raise Exception(
                f"CloudWatch response malformed:{cloudwatch_metric_results['Message']}"
            )
        metric_value = max(
            cloudwatch_metric_results["MetricDataResults"][default_first_index][
                "Values"
            ]
        )
        return metric_value

    def smallest_metric_from_results(
        self, cloudwatch_metric_results, default_first_index=0
    ):
        """
        Helper method which smallest metric value in the set.
        """
        if not cloudwatch_metric_results["MetricDataResults"]:
            raise Exception(
                f"CloudWatch response results empty:{cloudwatch_metric_results['MetricDataResults']}"
            )
        elif (
            not cloudwatch_metric_results["MetricDataResults"][default_first_index][
                "Timestamps"
            ]
            or not cloudwatch_metric_results["MetricDataResults"][default_first_index][
                "Values"
            ]
        ):
            raise Exception(
                f"CloudWatch response malformed:{cloudwatch_metric_results['Message']}"
            )
        metric_value = min(
            cloudwatch_metric_results["MetricDataResults"][default_first_index][
                "Values"
            ]
        )
        return metric_value

    def log_query(self, log_group, log_query, seconds_in_past, timeout=30):
        """
        Used to fetch a log query result from the CloudWatch Log Insights API endpoint.

        Examples:
        |   RW.AWS.CloudWatch.Log Query  |  ${AWS_LOG_GROUP}    |   ${LOG_QUERY}    |   ${SECONDS_IN_PAST}  |
        Return Value:
        |   logquery_result_set: json     |
        """
        seconds_in_past = int(seconds_in_past)
        client = self.get_client("logs")
        start_query_response = client.start_query(
            logGroupName=log_group,
            startTime=int(
                (datetime.now() - timedelta(seconds=int(seconds_in_past))).strftime(
                    "%s"
                )
            ),
            endTime=int(datetime.now().strftime("%s")),
            queryString=log_query,
        )
        query_id = start_query_response["queryId"]
        response = None
        timer = 0
        while (
            response == None
            or response["status"] == "Running"
            or response["status"] == "Scheduled"
            or timer >= timeout
        ):
            print("Waiting for query to complete ...")
            time.sleep(1)
            timer = timer + 1
            response = client.get_query_results(queryId=query_id)
        if timer >= timeout:
            raise Exception(f"Log Query: {log_query} timed out")
        return response

    def get_cloudwatch_metric_insights_url(self, region, metric_query):
        """
        Generates a shareable URL to a CloudWatch Metric Insights graph based on a query, usually ralated to an SLI.
        Examples:
        |   RW.AWS.CloudWatch.Get Cloudwatch Metric Insights Url  |  ${REGION}    |   ${METRIC_QUERY}                                |
        |   RW.AWS.CloudWatch.Get Cloudwatch Metric Insights Url  |  us-west-1    |   SELECT MAX(CPUUtilization) FROM \"AWS/EC2\"    |
        Return Value:
        |   link: str     |
        """
        encoded_query = f"graph=~(view~'timeSeries~metrics~(~(~(expression{self.aws_encode_var(metric_query)})))~region{self.aws_encode_var(region)})"
        url = f"https://{region}.console.aws.amazon.com/cloudwatch/home?region={region}#metricsV2:{encoded_query}"
        return url

    def get_cloudwatch_logs_insights_url(
        self,
        region,
        log_query,
        log_group,
        seconds_in_past,
    ):
        """
        TODO: Refactor all encoding code
        See for discussion and solutions:
        https://stackoverflow.com/questions/60796991/is-there-a-way-to-generate-the-aws-console-urls-for-cloudwatch-log-group-filters

        Generates a shareable URL to a CloudWatch Log Query Insights graph based on a query, usually ralated to an SLI.
        Examples:
        |   RW.AWS.CloudWatch.Get Cloudwatch Logs Insights Url  |  ${REGION}    |   ${LOG_QUERY}                                                      |  ${LOG_GRP}  |     SECONDS  |
        |   RW.AWS.CloudWatch.Get Cloudwatch Logs Insights Url  |  us-west-1    |   fields @timestamp, @message | sort @timestamp desc | limit 500    |  MyLogGroup  |     600      |
        Return Value:
        |   link: str     |
        """
        query_params = {
            "end": datetime.utcnow().isoformat(timespec="milliseconds") + "Z",
            "start": (
                datetime.utcnow() - timedelta(seconds=int(seconds_in_past))
            ).isoformat(timespec="milliseconds")
            + "Z",
            "timeType": "ABSOLUTE",
            "unit": "seconds",
            "editorString": log_query,
            "isLiveTrail": False,
            "source": log_group,
        }
        params = self.aws_quote_dict(query_params)
        object_string = self.aws_quote_logquery_str("~(" + "~".join(params) + ")")
        query_detail = quote(object_string, safe="*").replace("~", "%7E")
        result = quote(f"?queryDetail={query_detail}", safe="*").replace("%", "$")
        url = f"https://{region}.console.aws.amazon.com/cloudwatch/home?region={region}#logsV2:logs-insights{result}"
        return url

    # TODO: refactor encoding
    # Hacky encode code
    def aws_quote_list(self, param_list):
        quoted_list = ""
        for item in param_list:
            if isinstance(item, str):
                item = f"'{item}"
            quoted_list += f"~{item}"
        return f"({quoted_list})"

    def aws_quote_dict(self, param_dict):
        params = []
        for key, value in param_dict.items():
            if key == "editorString":
                value = "'" + quote(value)
                value = value.replace("%", "*")
            elif isinstance(value, str):
                value = "'" + value
            if isinstance(value, bool):
                value = str(value).lower()
            elif isinstance(value, list):
                value = self.aws_quote_list(value)
            params += [key, str(value)]
        return params

    def encode_aws_params(self, params):
        if isinstance(params, dict):
            params = self.aws_encode_dict(params)
        elif isinstance(params, list):
            params = self.aws_encode_list(params)
        else:
            params = self.aws_encode_var(params)
        return params
    # simplified encode
    def aws_encode_key(self, key):
        return f"~{str(key).lower()}"

    def aws_encode_var(self, param):
        if isinstance(param, str):
            param = f"'{self.aws_quote_metricquery_str(param)}"
            param = f"~{param}"
        elif isinstance(param, bool):
            param = str(param).lower()
            param = f"~{param}"
        return param

    def aws_quote_logquery_str(self, param_str):
        param_str = f"""{quote(param_str, safe="~()'*").replace('%', '*')}"""
        return param_str.replace("*2F", "*2f")

    def aws_quote_metricquery_str(self, param_str):
        param_str = f"""{quote(param_str, safe="~'*").replace('%', '*')}"""
        return param_str.replace("*2F", "*2f")

    def aws_glue_encoded_list(self, encoded_list):
        return "(".join(encoded_list)
