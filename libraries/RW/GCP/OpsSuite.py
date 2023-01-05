"""
Operations Suite keyword library

Scope: Global
"""
import json
import urllib
import re
import dateutil.parser
import google.auth.transport.requests
from datetime import datetime, timezone
from dataclasses import dataclass
from google.oauth2 import service_account
from google.cloud import monitoring_v3, logging
from google.protobuf.json_format import MessageToDict
from typing import Optional
from RW.Utils import parse_timedelta
from RW import platform, Prometheus


class OpsSuite():
    #TODO: move helpers to utils
    #TODO: update docstrings
    """
    Operations Suite keyword library
    """

    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def __init__(self):
        self._credentials = None

    def authenticate(self, service_account_json: platform.Secret):
        """
        Sets the google service account credentials from a platform secret containing json.
        - ``service_account_json`` the secret containing a json string from a google account credentials file.

        Examples:
        | RW.GCP.OpsSuite.Set Opssuite Credentials  |   ${opssuite_sa_creds}
        """
        if not service_account_json:
            raise ValueError(f"service_account is empty")
        sa = json.loads(service_account_json.value, strict=False)
        self._credentials = service_account.Credentials.from_service_account_info(sa)

    def get_credentials(self) -> object:
        """
        Return the credentials.
        :return: The credentials
        """
        return self._credentials

    def get_token(self, gcp_credentials : platform.Secret=None) -> platform.Secret:
        """
        Retrieve short lived bearer token from service account authentication in the form of a platform secret.

        Examples:
        | RW.GCP.OpsSuite.Get Token  | gcp_credentials=${ops-suite-sa}
        Return Value:
        | A secret in the form of key=token value=access_token, good for 3600s.   |
        """
        if not gcp_credentials:
            raise ValueError(f"service_account is empty")
        sa = json.loads(gcp_credentials.value, strict=False)
        creds = service_account.Credentials.from_service_account_info(sa, scopes=['https://www.googleapis.com/auth/cloud-platform'])
        
        # See https://cloud.google.com/docs/authentication/token-types#access-contents
        # Access tokens are by default good for 1 hour / 3600 seconds 
        # https://github.com/googleapis/google-auth-library-python/blob/main/google/oauth2/service_account.py

        request = google.auth.transport.requests.Request()
        creds.refresh(request)
        return platform.Secret(key="token", val=creds.token)

    def get_access_token_header(self, gcp_credentials : platform.Secret=None) -> platform.Secret:
        """
        Retrieve an access token header with a short lived bearer token from service account 
        authentication in the form of a platform secret.

        Examples:
        | RW.GCP.OpsSuite.Get Access Token Header  | gcp_credentials=${ops-suite-sa}
        Return Value:
        | A secret in the form of key=optional_headers value='{"Authorization": "Bearer [token]"}', good for 3600s.   |
        """
        access_token = self.get_token(gcp_credentials)
        access_token_header = {"Authorization":"Bearer {}".format(access_token.value)}
        return platform.Secret(key="optional_headers", val=json.dumps(access_token_header))

    def run_mql(self, project_name, mql_statement, sort_most_recent=True):
        """
        *DEPRECATED*
        Runs a MQL statement against a project ID in Google cloud, and returns a timeseries of monitoring data.
        - ``project_name`` the Google Cloud Project ID
        - ``mql_statement`` is the MQL statement to execute.

        ``tip:`` you can play with a MQL statement in the Google Cloud Console and paste it into the SLI config.

        Examples:
        | RW.GCP.OpsSuite.Run Mql   |   ${PROJECT_ID}   |   ${MQL_STATEMENT}
        Return Value:
        | response dict   |
        """
        client = monitoring_v3.QueryServiceClient(credentials=self.get_credentials())
        request = monitoring_v3.QueryTimeSeriesRequest(
            name=f"projects/{project_name}",
            query=mql_statement,
        )
        page_result = client.query_time_series(request=request)
        rsp = [type(r).to_dict(r) for r in page_result]
        return rsp

    def metric_query(self, project_name, mql_statement, no_result_overwrite, no_result_value, gcp_credentials : platform.Secret=None, sort_most_recent=True):
        """
        Runs a MQL statement against a project ID in Google cloud, and returns a timeseries of monitoring data.
        - ``project_name`` the Google Cloud Project ID
        - ``mql_statement`` is the MQL statement to execute.

        ``tip:`` you can play with a MQL statement in the Google Cloud Console and paste it into the SLI config.

        Examples:
        | RW.GCP.OpsSuite.Run Mql   |   ${PROJECT_ID}   |   ${MQL_STATEMENT}    |
        Return Value:
        | response dict   |
        """
        if gcp_credentials:
            self.authenticate(gcp_credentials)
        client = monitoring_v3.QueryServiceClient(credentials=self.get_credentials())
        request = monitoring_v3.QueryTimeSeriesRequest(
            name=f"projects/{project_name}",
            query=mql_statement,
        )
        page_result = client.query_time_series(request=request)
        rsp = [type(r).to_dict(r) for r in page_result] # convert protobuf rsp to dict
        if no_result_overwrite == 'Yes': 
            if not rsp: 
              metric = int(no_result_value)
            else: 
              metric = self._extract_metric_from_mql_result(rsp, sort_most_recent)
        else: 
          metric = self._extract_metric_from_mql_result(rsp, sort_most_recent)  
        return metric

    def _extract_metric_from_mql_result(
        self,
        metric_query_result: {},
        sort_most_recent: bool,
        data_key="point_data",
    ) -> {}:
        # TODO: convert to an extract/parse strategy
        metric_data = metric_query_result[0][data_key]
        if len(metric_data) == 0:
            raise ValueError(f"The MQL result set has 0 results: {metric_query_result}")
        if sort_most_recent:
            metric_data = sorted(metric_data, key=lambda d: dateutil.parser.parse(d["time_interval"]["end_time"]))
        # first access mql result array, access values list, get 0th entry which has/can be sorted to most recent
        # then get dict values so we don't need to check keys, cast values to list and get 0th
        metric = list(metric_data[0]["values"][0].values())[0]
        # first attempt regular format
        try:
            metric = format(float(metric), "f")
        except:
            # TODO: log exception before continuing
            # remove alpha characters from value and assume float cast
            metric = float(''.join(i for i in str(metric) if i.isdigit() or i in ['.', '-']))
        return metric
    
    def get_last_point_in_series_set(self, mql_result, label_key="label_values", data_key="point_data"):
        """
        *DEPRECATED*
        Removes all data points except the most recent for each instance in the MQL result set.
        - ``mql_result`` the results from an MQL statement

        Examples:
        | RW.GCP.OpsSuite.Get Last Point In Series Set  |   ${rsp}
        Return Value:
        | results dict   |
        """
        parsed_points_set = []
        for series in mql_result:
            if series[data_key]:
                parsed_points_set.append({label_key: series[label_key], data_key: series[data_key][0]})
        return parsed_points_set
    
    def average_numeric_across_instances(
        self, 
        data_points, 
        label_key="label_values", 
        data_key="point_data",
        point_type="double_value"
    ):
        """
        *DEPRECATED*
        Returns the average of a MQL result set containing numerical data points.
        - ``data_points`` the results from an MQL statement parsed to have singular data pointers per instance

        Examples:
        | RW.GCP.OpsSuite.Average Numeric Across Instances  |   ${parsed_points}
        Return Value:
        | average float |
        """
        avg = sum([d[data_key]["values"][0][point_type] for d in data_points])/len(data_points)
        return avg
    
    def highest_numeric_across_instances(
        self,
        data_points,
        label_key="label_values",
        data_key="point_data",
        point_type="double_value"
    ):
        """
        *DEPRECATED*
        Returns the highest value from a MQL result set.
        - ``data_points`` the results from an MQL statement parsed to have singular data pointers per instance

        Examples:
        | RW.GCP.OpsSuite.Highest Numeric Across Instances  |   ${parsed_points}
        Return Value:
        | highest numeric |
        """
        values = [d[data_key]["values"][0][point_type] for d in data_points]
        highest = max(values)
        return highest
    
    def sum_numeric_across_instances(
        self,
        data_points,
        label_key="label_values",
        data_key="point_data",
        point_type="double_value"
    ):
        """
        *DEPRECATED*
        Returns the sum of values from a MQL result set.
        - ``data_points`` the results from an MQL statement parsed to have singular data pointers per instance

        Examples:
        | RW.GCP.OpsSuite.Sum Numeric Across Instances  |   ${parsed_points}
        Return Value:
        | numeric sum |
        """
        if point_type == "double_value":
            values = [float(d[data_key]["values"][0][point_type]) for d in data_points]
        elif point_type == "int64_value":
            values = [int(d[data_key]["values"][0][point_type]) for d in data_points]
        return sum(values)

    def remove_units(
        self,
        data_points,
        label_key="label_values",
        data_key="point_data",
        point_type="double_value"
    ):
        """
        *DEPRECATED*
        Iterates over a MQL result set and removes alpha characters to allow math ops.
        - ``data_points`` the results from an MQL statement parsed to have singular data pointers per instance

        Examples:
        | RW.GCP.OpsSuite.Remove Units  |   ${parsed_points}
        Return Value:
        | MQL result set with numerical data points |
        """
        cleaned = []
        for d in data_points:
            data = d[data_key]["values"][0][point_type]
            data = float(''.join(i for i in data if i.isdigit() or i in ['.', '-']))
            d[data_key]["values"][0][point_type] = data
            cleaned.append(d)
        return cleaned

    def get_gce_logs(
        self, project_name: str = None, log_filter: str = None, limit: int = 1000, gcp_credentials:platform.Secret=None, logger_name: str = "stderr"
    ) -> object:
        """
        Get logs from GCE logging based on filter
        Note: because we're forgoeing the use of the generator to provide an easy interface, using a limit and filter is important for performance
        return: str
        """
        if gcp_credentials:
            self.authenticate(gcp_credentials)
        logging_client = logging.Client(credentials=self.get_credentials())
        logger = logging_client.logger(f"{logger_name}")
        logs = []
        for log in logger.list_entries(
            resource_names=[f"projects/{project_name}"],
            filter_=log_filter,
            max_results=limit,
            order_by="timestamp desc",
        ):
            logs.append(log.payload)
        return json.dumps(logs)

    def get_logs_dashboard_url(self, project_id: str, gcloud_filter: str, hostname: str = "https://console.cloud.google.com/logs/query") -> str:
        """
        Generates a encoded URL to a gcloud logging dashboard with the equivalent query used to detect reported errors
        BUG: using '>=' or similar operators in the query string can break the url when the request hits the dashboard; eg: use '>' instead
        return: str
        """
        params = {"project": project_id}
        # quote filter separately since it uses different server separator symbol
        encoded_filter = ";query=" + urllib.parse.quote(gcloud_filter)
        url = hostname + encoded_filter + "?" + urllib.parse.urlencode(params, quote_via=urllib.parse.quote)
        return url

    def add_time_range(self, base_query, within_time:str="1h") -> str:
        past_time = (datetime.now(timezone.utc) - parse_timedelta(within_time)).strftime("%Y-%m-%dT%H:%M:%SZ")
        now = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
        time_range = f" AND timestamp > \"{past_time}\" AND timestamp < \"{now}\""
        time_ranged_query = base_query + time_range
        return time_ranged_query