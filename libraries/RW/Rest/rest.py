import requests
from requests.auth import HTTPBasicAuth

import logging
import urllib
import json
import jmespath
import dateutil.parser
from RW import platform
from RW.Utils.utils import is_json, from_json
from typing import Union

from datetime import datetime, timedelta

logger = logging.getLogger(__name__)


class Rest:
    """
    A keyword library for housing general-purpose REST keywords.
    Note: session was avoided on purpose to reduce state
    TODO: support explicit oauth2 flow
    """

    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def request(
        self,
        url,
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
            url: the URL to perform the request against. Should be a secret or string type.
            method (str, optional): the verb to use during the HTTP request. Defaults to "GET".

        Refer to requests.request documentation for other parameters as these will be passed through via kwargs.

        Returns:
            requests.Response: the Response object.
        """
        for request_field in ["params", "data", "json", "headers"]:
            if request_field in kwargs.keys() and is_json(kwargs.get(request_field)):
                kwargs[request_field] = from_json(kwargs.get(request_field))
            if request_field in kwargs.keys() and isinstance(kwargs.get(request_field), platform.Secret):
                request_secret: platform.Secret = kwargs.pop(request_field)
                secret_val = request_secret.value
                if is_json(secret_val):
                    kwargs[request_field] = from_json(secret_val)
                else:
                    kwargs[request_field] = secret_val
        # if the url is a secret like a webhook, get the value
        if isinstance(url, platform.Secret):
            url = url.value
        rsp: requests.Response = requests.request(url=url, method=method, **kwargs)
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
        if rsp_as_json and not rsp_extract_json_path:
            rsp = rsp.json()
        if rsp_extract_json_path:
            rsp = self.handle_response(rsp=rsp, json_path=rsp_extract_json_path)
        return platform.Secret(created_secret_key, rsp)

    def handle_response(
        self,
        rsp: requests.Response,
        json_path: str = None,
        expected_status_codes: list[int] = [200, 201, 204],
    ) -> any:
        """Generic handler for inspecting the response received from a HTTP request.
        It can verify the response status code and extract data from the response object based on a
        json_path string allowing users to provide query-like config and handle generalized json responses.

        Note: if the server did not respect json as the content type in its response, then this may fallback to text

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
        rsp_data = ""
        if rsp.status_code not in expected_status_codes:
            raise requests.RequestException(
                f"The HTTP response code {rsp.status_code} is not in the expected list {expected_status_codes} for {rsp}"
            )
        # attempt to fetch json response
        # if server did not respect content type then fallback to text
        try:
            rsp_data = rsp.json()
        except Exception as e:
            logger.info(f"Failed to parse json response due to: {e} - falling back to text")
            rsp_data = rsp.text
        if json_path and is_json(rsp_data):
            rsp_data = jmespath.search(json_path, rsp_data)
            if rsp_data == None:
                raise ValueError(
                    f"the json_path {json_path} did not return a valid value from the json document: {rsp_data}"
                )
        return rsp_data

    def create_basic_auth(self, username: platform.Secret, password: platform.Secret) -> requests.auth.HTTPBasicAuth:
        """
        Takes a username and password as platform secrets and uses them to construct a requests.auth.HTTPBasicAuth object.
        The resulting object properly encapsulates the credentials and so does not require being wrapped in a platform secret itself.

        Args:
            username (platform.Secret): the username to use.
            password (platform.Secret): the password to use.

        Returns:
            requests.auth.HTTPBasicAuth: auth object to be used as the `auth` parameter in other keywords.
        """
        return requests.auth.HTTPBasicAuth(username=username.value, password=password.value)

    def create_basic_auth_secret(self, username: platform.Secret, password: platform.Secret) -> platform.Secret:
        basic_auth_data = {"username": username.value, "password": password.value}
        basic_auth_json = json.dumps(basic_auth_data)
        basic_auth_data: platform.Secret = platform.Secret(key="basic_auth", val=basic_auth_json)
        return basic_auth_data

    def create_bearer_token_header(self, token: Union[platform.Secret, str]) -> platform.Secret:
        if isinstance(token, platform.Secret):
            token = token.value
        bearer_token: platform.Secret = platform.Secret("bearer_token", '{"Authorization":"Bearer ' + token + '"}')
        return bearer_token
