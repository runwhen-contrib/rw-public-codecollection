import requests
import logging
import urllib
import json
import jmespath
import dateutil.parser
from RW import platform
from RW.Utils.utils import is_json, from_json

from datetime import datetime, timedelta

logger = logging.getLogger(__name__)


class Rest:
    """
    A keyword library for housing general-purpose REST keywords.
    TODO: support explicit oauth2 flow
    """

    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def request(
        self,
        url: str,
        method: str = "GET",
        **kwargs,
    ) -> requests.Response:
        """
        A wrapper method for the requests module. See requests.request(method, url, **kwargs) for parameter behaviours.
        This method performs some parameter validation and secret handling before handing the request off to requests.
        - use the `json` parameter for your rest data, this will set the "Content-Type":"application/json" header for you.
        - headers should be provided in a platform.Secreet type but can be provided as json
        - if params, json or headers are passed as json strings, they will be converted to dictionaries.

        Args:
            url (str): the URL to perform the request against.
            method (str, optional): the verb to use during the HTTP request. Defaults to "GET".

        Refer to requests.request documentation for other parameters as these will be passed through via kwargs.

        Returns:
            requests.Response: the Response object.
        """
        # handle headers if passed in as platform secret
        if "headers" in kwargs.keys() and isinstance(kwargs.get("headers"), platform.Secret):
            headers: platform.Secret = kwargs.pop("headers")
            headers_val = headers.value
            if is_json(headers_val):
                headers = from_json(headers_val)
        # for fields expected to be json strings, convert to dictionaries
        for request_field in ["params", "json", "headers"]:
            if request_field in kwargs.keys() and is_json(kwargs.get(request_field)):
                kwargs[request_field] = from_json(kwargs.get(request_field))
        rsp: requests.Response = requests.request(url=url, method=method, headers=headers, **kwargs)
        return rsp

    def request_as_secret(
        self,
        created_secret_key: str,
        rsp_as_json: bool = True,
        rsp_extract_json_path: str = None,
        **kwargs,
    ) -> platform.Secret:
        """A wrapper utility function for users to avoid authors dropping into the python layer
        when handling secrets. Use this if you'd like to request a token secretly for use elsewhere in robot.

        Args:
            created_secret_key (str): the key set in the secret returned.
            rsp_as_json (bool, optional): returns the rsp.json() content as the secret value. Defaults to True.
            rsp_extract_json_path (str, optional): overrides rsp_as_json and insteads fetches a value from a json path. Defaults to None.

        Returns:
            platform.Secret: a platform secret containing the rsp content.
        """
        rsp: requests.Response = self.request(**kwargs)
        if rsp_as_json and not rsp_extract_key:
            rsp = rsp.json()
        if rsp_extract_key:
            rsp = self.handle_response(rsp=rsp, json_path=rsp_extract_json_path)
        return platform.Secret(created_secret_key, rsp)

    def handle_response(
        self,
        rsp: requests.Response,
        json_path: str = None,
        expected_status_codes: list[int] = [200, 201],
    ) -> any:
        """Generic handler for inspecting the response received from a HTTP request.
        It can verify the response status code and extract data from the response object based on a
        json_path string allowing users to provide query-like config and handle generalized json responses.

        Args:
            rsp (requests.Response): the rsp ojbect to validate/extract data from.
            json_path (str, optional): if provided, transform/extract data from the json path. Defaults to None.
            expected_status_codes (list[int], optional): the list of acceptable response status codes. Defaults to [200, 201].

        Raises:
            requests.RequestException: raised if the status code is not within the expected set.
            ValueError: raised if the json path returns nothing from the json document.

        Returns:
            any: the return type depends on what is extracted from the json document.
        """
        rsp_data = None
        if rsp.status_code not in expected_status_codes:
            raise requests.RequestException(
                f"The HTTP response code {rsp.status_code} is not in the expected list {expected_status_codes} for {rsp}"
            )
        rsp_data = rsp.json()
        logger.info(f"Handling rsp json: {rsp_data}")
        if json_path:
            rsp_data = jmespath.search(json_path, rsp_data)
            if rsp_data == None:
                raise ValueError(
                    f"the json_path {json_path} did not return a valid value from the json document: {rsp_data}"
                )
        return rsp_data
