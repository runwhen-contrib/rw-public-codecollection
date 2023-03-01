"""
Datadog keyword library

Scope: Global
"""
import time, os
from dataclasses import dataclass
from typing import Union, Optional
from RW.Utils import utils
from RW import platform


from datetime import datetime, timezone
from dateutil.relativedelta import relativedelta
from datadog_api_client import ApiClient, Configuration
from datadog_api_client.v1.api.metrics_api import MetricsApi

STATUS_KEY = "status"


class Datadog:
    """
    Datadog is a keyword library for integrating with Datadog product.

    You need to provide a Datadog API Key and a Datadog App Key to use
    this library.

    """

    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def handle_timeseries_data(
        self, rsp: dict,
        json_path: str = "series[0].pointlist[-1][1]",
        no_result_overwrite="No",
        no_result_value:float=0.0,
    ) -> any:
        """
        Takes a datadog timeseries response and extracts data from it using a jmespath json path string.
        Verifies the status is OK.

        Args:
            rsp (dict): the datadog timeseries response
            json_path (str, optional): the json path used to extract timeseries data. Defaults to "series[0].pointlist[-1][1]".

        Raises:
            Exception: raised when the status is not ok, or when no data could be extracted

        Returns:
            any: varies depending on the extracted data.
        """
        no_result_overwrite: bool = True if no_result_overwrite == "Yes" else False
        if rsp[STATUS_KEY] != "ok":
            raise Exception(f"status of response not ok: {rsp}")
        extracted_data = utils.search_json(rsp, json_path)
        if extracted_data == None and no_result_overwrite:
            extracted_data = no_result_value
        elif extracted_data == None:
            raise Exception(f"No data could be extracted with json path: {json_path} on rsp: {rsp} got return: {extracted_data} - consider using the no_result_overwrite option")
        return extracted_data

    def metric_query(
        self,
        api_key: platform.Secret,
        app_key: platform.Secret,
        query_str: str,
        within_time: str = "60s",
        site: str = "datadoghq.com",
    ) -> dict:
        """
        Returns a timeseries result from the datadog metric timeseries API.
        You can extract data from this response using the handle_timeseries_data keyword.

        Args:
            api_key (platform.Secret): secret containing the datadog api string
            app_key (platform.Secret): secret containing the app key string for your app
            query_str (str): the datadog metric query string
            within_time (str, optional): the time window for the time series. Defaults to "60s".
            site (str, optional): which region to hit for the datadog API. Defaults to "datadoghq.com".

        Returns:
            object: the dictionary response containing the datadog timeseries data.
        """
        # place keys into dict for client quirk - check Configuration source
        api_key_dict = {
            "apiKeyAuth": api_key.value,
            "appKeyAuth": app_key.value,
        }
        configuration = Configuration(server_variables={"site": site}, api_key=api_key_dict)
        with ApiClient(configuration) as api_client:
            api_instance = MetricsApi(api_client)
            within_time: datetime.timedelta = utils.parse_timedelta(within_time)
            end_time: int = int(datetime.now(timezone.utc).timestamp())
            start_time: int = int(((datetime.now(timezone.utc) - within_time)).timestamp())
            rsp = api_instance.query_metrics(
                _from=start_time,
                to=end_time,
                query=query_str,
            )
        # cast https://datadoghq.dev/datadog-api-client-python/datadog_api_client.v1.model.html#datadog_api_client.v1.model.metrics_query_response.MetricsQueryResponse
        # to dict
        rsp = rsp.to_dict()
        return rsp
