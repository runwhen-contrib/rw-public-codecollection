import requests
import logging
import urllib
import json
import dateutil.parser

from datetime import datetime, timedelta
from RW import platform

logger = logging.getLogger(__name__)

class Prometheus:
    """
    Keyword Integration for the Prometheus HTTP API which can be used to fetch data from a Prometheus instance.
    Implemented according to https://prometheus.io/docs/prometheus/latest/querying/api/
    """
    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def _query(self, url, target_service: platform.Service=None, optional_headers: platform.Secret=None, params=None, timeout=30):
        """
        API request method wrapped by other public query methods.
        """
        if target_service:
            # if a runwhen service is provided, pass an equivalent curl to it instead
            # If optional_headers are provided
            rsp = self._query_with_service(
                url=url,
                params=params,
                optional_headers=optional_headers,
                target_service=target_service
            )          
        else:
            # else we assume the prometheus instance is public
            headers = {
                "content-type":"application/json",
            }
            if optional_headers:
                optional_headers = json.loads(optional_headers.value)
                headers.update(optional_headers)
                rsp = requests.get(url, headers=headers, params=params, timeout=timeout)
            else:
                rsp = requests.get(url, params=params, timeout=timeout)
                
            if rsp.status_code != 200:
                raise ValueError(f"Received HTTP code {rsp.status_code} in response {rsp} against url {url} and params {params}")
            rsp = rsp.json()
        if "status" not in rsp or "data" not in rsp:
            raise ValueError(f"Response received is malformed {rsp} against url {url} and params {params}")
        if rsp["status"] == "error":
            raise ValueError(f"API responded with error {rsp} against url {url} and params {params}")
        return rsp

    def _secret_to_curl_headers(self, optional_headers: platform.Secret) -> platform.Secret:
        header_list = []
        headers = {
            "content-type":"application/json",
        }
        headers.update(json.loads(optional_headers.value))
        for k,v in headers.items():
            header_list.append(f"-H \"{k}: {v}\"")
        optional_headers: platform.Secret = platform.Secret(key=optional_headers.key, val=" ".join(header_list))
        return optional_headers

    def _create_curl(self, url, optional_headers: platform.Secret=None, params=None) -> str:
        """
        Helper method to generate a curl string equivalent to a Requests object (roughly)
        Note that headers are inserted as a $variable to be substituted in the location service by an environment variable.
        This is identified by the secret.key
        """
        if params:
            params = f"?{urllib.parse.urlencode(params, quote_via=urllib.parse.quote)}"
        else:
            params = ""
        # we use eval so that the location service evaluates the secret headers as multiple tokens
        if optional_headers:
            curl = f"eval $(echo \"curl -X GET ${optional_headers.key} '{url}{params}'\")"
        else:
            curl = f"eval $(echo \"curl -X GET '{url}{params}'\")"
        return curl

    def _query_with_service(
        self, url: str,
        target_service: platform.Service,
        optional_headers: platform.Secret=None,
        params=None,
    ) -> dict:
        """
        Passes a curl string over to a RunWhen location service which handles the request and returns the stdout.
        """
        curl_str: str = self._create_curl(url, optional_headers, params=params)
        if optional_headers:
            optional_headers = self._secret_to_curl_headers(optional_headers=optional_headers)
            request_optional_headers = platform.ShellServiceRequestSecret(optional_headers)
            rsp = platform.execute_shell_command(
                cmd=curl_str,
                service=target_service,
                request_secrets=[request_optional_headers]
            )
        else:
            rsp = platform.execute_shell_command(
                cmd=curl_str,
                service=target_service,
            )
        
        if rsp.status != 200:
            raise ValueError(f"Received HTTP status of {rsp.status} from response {rsp}")
        if rsp.returncode > 0:
            raise ValueError(f"Recieved return code of {rsp.returncode} from response {rsp}")
        rsp = json.loads(rsp.stdout)
        return rsp

    def query_instant(
        self,
        api_url,
        query,
        step: str=None,
        target_service: platform.Service=None,
        optional_headers: platform.Secret=None,
        point_in_time = None
    ):
        """
        Performs a query against the prometheus instant API for metrics with a single data point.

        Examples:
        | ${rsp}=    |  RW.Prometheus.Instant Query    |    ${PROM_HOSTNAME}    |   ${OPTIONAL_HEADERS}    | ${PROM_QUERY}  |
        | ${rsp}=    |  RW.Prometheus.Instant Query    |    https://my-prometheus/prometheus/api/v1/   |   {"opt-header": "value"}    | my_metric_name  |

        Return Value:
        |   prometheus_response: dict  |
        """
        if point_in_time == None:
            point_in_time=datetime.now()
        time = f"{point_in_time.isoformat()}Z"
        api_url = f"{api_url}/query"
        params = {
            "query":f"{query}",
            "time": f"{time}",
        }
        if step:
            params["step"] = step
        return self._query(api_url, target_service=target_service, optional_headers=optional_headers, params=params)

    def query_range(
        self,
        api_url,
        query,
        target_service: platform.Service=None,
        optional_headers: platform.Secret=None,
        step="30s",
        seconds_in_past=60,
        start=None,
        end=None,
        use_unix_seconds:bool=False
    ):
        """
        Performs a query against the prometheus Range API for metric data containing lists of data points.

        Examples:
        | ${rsp}=    |  RW.Prometheus.Range Query    |    ${PROM_HOSTNAME}    | ${PROM_QUERY}  |    ${OPTIONAL_HEADERS}  |
        | ${rsp}=    |  RW.Prometheus.Range Query    |    https://my-prometheus/prometheus/api/v1/   |   {"opt-header": "value"}    | my_metric_name  | step=30 | seconds_in_past=600   |

        Return Value:
        |   prometheus_response: dict  |
        """
        api_url = f"{api_url}/query_range"
        if start:
            start = f"{start.isoformat()}Z"
        else:
            start = f"{(datetime.now() - timedelta(seconds=int(seconds_in_past))).isoformat()}Z"
        if end:
            end = f"{end.isoformat()}Z"
        else:
            end = f"{datetime.now().isoformat()}Z"
        if use_unix_seconds:
            start = f"{int(dateutil.parser.parse(start).timestamp())}"
            end = f"{int(dateutil.parser.parse(end).timestamp())}"
        params = {
            "query":f"{query}",
            "start": f"{start}",
            "end": f"{end}",
            "step": f"{step}",
        }
        return self._query(api_url, target_service=target_service, optional_headers=optional_headers, params=params)

    def list_labels(self, api_url, target_service: platform.Service=None, optional_headers: platform.Secret=None):
        """
        Performs a query against the prometheus labels API that provides a list of all labels under the organization.

        Examples:
        | ${rsp}=    |  RW.Prometheus.List Labels    |    ${PROM_HOSTNAME}    |   ${OPTIONAL_HEADERS}    |
        | ${rsp}=    |  RW.Prometheus.List Labels    |    https://my-prometheus/prometheus/api/v1/   |   {"opt-header": "value"}    |

        Return Value:
        |   prometheus_response: dict  |
        """
        api_url = f"{api_url}/labels"
        params = {}
        return self._query(api_url, target_service=target_service, optional_headers=optional_headers, params=params)

    def query_label(self, api_url, label, target_service: platform.Service=None, optional_headers: platform.Secret=None):
        """
        Performs a query against the prometheus labels API that provides a list of all values under a label.

        Examples:
        | ${rsp}=    |  RW.Prometheus.List Labels    |    ${PROM_HOSTNAME}    |   ${OPTIONAL_HEADER}    |
        | ${rsp}=    |  RW.Prometheus.List Labels    |    https://my-prometheus/prometheus/api/v1/   |   {"opt-header": "value"}    |   my_label    |

        Return Value:
        |   prometheus_response: dict  |
        """
        api_url = f"{api_url}/label/{label}/values"
        return self._query(api_url, target_service=target_service, optional_headers=optional_headers)

    def transform_data(
        self,
        data,
        method: str,
        no_result_overwrite: bool=False,
        no_result_value: float=0,
        column_index=1,
        metric_name=None
    ):
        """
        A helper method which can parse and transform data from a Prometheus API response.
        In the below examples, ${data} is typically referencing ${rsp["data"]} from
        an above API request.
        The First and Last options are position relative, so Last is the most recent metric value.

        Examples:
        ${transform}=    RW.Prometheus.transform Data    ${data}    Average

        Return Value:
        |   transform_value: float  |
        """
        column_index = int(column_index)
        if "result" not in data or len(data["result"]) == 0:
            if no_result_overwrite:
                return no_result_value
            else:
                raise ValueError(f"Empty metric results {data}")
        metric_index = None
        # find index of metric in results if name provided
        if metric_name:
            for i, metric in enumerate(data["result"]):
                if metric["__name__"] == metric_name:
                    metric_index = i
        # else assume first
        else:
            metric_index = 0
        # TODO: make configurable
        first_data_point = 0

        if metric_index != 0 and not metric_index:
            raise ValueError(f"Could not identify metric index for {metric_name} in data {data}")

        if "value" in data["result"][metric_index]:
            metric_data = data["result"][metric_index]["value"]
            if method == "Raw":
                return metric_data[column_index]
        elif "values" in data["result"][metric_index]:
            metric_data = data["result"][metric_index]["values"]
            if method == "Raw":
                return metric_data[first_data_point][column_index]
            column = [float(row[column_index]) for row in metric_data]
            if method == "Max":
                return max(column)
            elif method == "Average":
                return sum(column) / len(column)
            elif method == "Minimum":
                return min(column)
            elif method == "Sum":
                return sum(column)
            elif method == "First":
                return column[0]
            elif method == "Last":
                return column[-1]
            else:
                raise ValueError(f"Invalid transform method {method} provided for aggregation on list")
