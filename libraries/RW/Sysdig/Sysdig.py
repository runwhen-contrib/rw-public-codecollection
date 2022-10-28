"""
Sysdig keyword library

Scope: Global
"""
import logging
from sdcclient import SdMonitorClient
from dataclasses import dataclass
from typing import Union, Optional
from RW.Core import Core
from RW import platform
from RW.Utils import utils
from RW.Utils.utils import Status
from RW.Prometheus import Prometheus

logger = logging.getLogger(__name__)


class Sysdig:
    """
    Sysdig is a keyword library for integrating with the Sysdig Secure and Monitor products.

    Note: Only Sysdig Monitor product is supported at this time.

    You need to provide a Sysdig region URL and a Sysdig Monitor API Token to use
    this library.

    """

    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def __init__(self):
        """
        Initialize prometheus client for wrapper calls.
        """
        self._prometheus = Prometheus()

    def get_metrics_dict(self, token: platform.Secret, sdc_url: str, metric_filter: str = "") -> dict:
        """
        Return a dict of metrics that describe a metric and it's possible operations. Filterable by name.

        Examples:
        | Get Metrics Dict |

        Return Value:
        | Dict of metrics |
        """
        client = SdMonitorClient(token=token.value, sdc_url=sdc_url)
        rsp_ok, rsp = client.get_metrics()
        if not rsp_ok:
            raise ValueError(f"Received error response: {rsp}")
        filtered_rsp = {}
        if metric_filter:
            for metric_id, metric in rsp.items():
                logger.debug("Comparing %s to %s", metric_filter, metric_id)
                if metric_filter in metric_id:
                    filtered_rsp[metric_id] = metric
            rsp = filtered_rsp
        return rsp

    def get_metrics_list(self, token: platform.Secret, sdc_url: str, metric_filter: str = "") -> list:
        """Fetches a list of metric names available. Filterable by name.

        Args:
            token (platform.Secret): the auth token used to authenticate with the sysdig endpoint.
            sdc_url (str): the sysdig endpoint.
            metric_filter (str, optional): the value used to filter metric names with. Defaults to "".

        Returns:
            list: a list of metric names.
        """
        metrics: dict = self.get_metrics_dict(token, sdc_url, metric_filter=metric_filter)
        return list(metrics.keys())

    def get_metric_data(
        self,
        token: platform.Secret, 
        sdc_url: str,
        query_str: str,
        time_window: int = 600,
        sampling: Optional[int] = None,
        data_filter: Optional[str] = None,
        get_most_recent: bool = True,
    ) -> object:
        """
        Get the metrics given a Sysdig query.

        The ``time_window`` is the size of the data window. For example,
        600 seconds will return the metrics seen in the past 10 minutes.

        ``sampling`` specifies the duration of the samples. 60 seconds sampling
        for a 600 seconds ``time_window`` will return 10 metrics. To return a
        single metric sample, don't specify a ``sampling`` value (default).

        ``data_filer`` is used to further fine tune the query result.

        ``get_most_recent`` gets the newest metric data value.

        Refer to the Sysdig Data API for more details - https://docs.sysdig.com/en/docs/developer-tools/working-with-the-data-api/

        Examples:
        | ${res} = | RW.Sysdig.Get Metrics | [{"id": "cpu.used.percent", "aggregations": {"time": "timeAvg", "group": "avg"}}] | 60 |

        Return Values:
        | Metric data |
        """
        client = SdMonitorClient(token=token.value, sdc_url=sdc_url)
        logger.info("Connected to endpoint: %s", sdc_url)
        start_time = -(time_window)
        end_time = 0
        if sampling is None:
            sampling = time_window
        query_data = utils.from_json(query_str)
        logger.info("Using query data:\n %s", query_data)
        rsp_ok, rsp = client.get_data(
            query_data,
            start_time,
            end_time,
            sampling,
            data_filter,
        )
        if not rsp_ok:
            raise ValueError(f"Received error response: {rsp}")
        metric_data = rsp
        logger.debug("Response metric data:\n %s", metric_data)
        if get_most_recent and len(rsp["data"]) > 0:
            metric_data = rsp["data"][-1]["d"][0]
        return metric_data

    def promql_query(
        self,
        api_url: str,
        query: str,
        target_service: platform.Service=None,
        optional_headers: platform.Secret=None,
        step="30s",
        seconds_in_past=60,
        start=None,
        end=None,
    ):
        """A wrapper method for the prometheus query method. This performs a Prometheus-compatible query against a
        sysdig promql api endpoint so that promql statements may be used to fetch metrics sitting behind sysdig.

        Args:
            api_url (str): the sysdig promql API url
            query (str): the promql statement to execute
            target_service (platform.Service, optional): A RunWhen location service if needed, used for making requests against instances in a VPC. Defaults to None.
            optional_headers (platform.Secret, optional): headers used when making requests against the prometheus API. Add your auth info to this.. Defaults to None.
            step (str, optional): interval between datapoints returned. Defaults to "30s".
            seconds_in_past (int, optional): How far back in the past in seconds to fetch data. Defaults to 60.
            start (_type_, optional): overrides seconds in past and sets the start time. Defaults to None.
            end (_type_, optional): overrides seconds in past and sets the end time. Defaults to None.
            use_unix_seconds (bool, optional): converts timestamps to unix timestamps. Can be used for varying Prometheus instance requirements.

        Returns:
            _type_: _description_
        """
        rsp = self._prometheus.query_range(
            api_url=api_url,
            query=query,
            target_service=target_service,
            optional_headers=optional_headers,
            step=step,
            seconds_in_past=seconds_in_past,
            start=start,
            end=end,
            use_unix_seconds=True
        )
        return rsp

    def transform_data(self, data, method):
        """Performs a transform on a list of data points, sometimes this can be very simple such as fetching the last value in the list.

        Args:
            data (list): a list of data points to perform a transform on
            method (str): what transform operation to perform on the list of data points

        Returns:
            float: transformed data
        """
        transformed = self._prometheus.transform_data(data, method)
        return transformed
