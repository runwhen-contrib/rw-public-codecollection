"""Simple REST client"""

import re
import requests
from typing import Optional, Union
from RW.Utils import utils

REQUESTS_TIMEOUT = 45

#TODO: delete & cleanup to simplify HTTP interfaces - still in use by HTTP module

def create_session(headers: Union[str, object, None]) -> object:
    session = requests.Session()
    update_session_headers(session, headers)
    return session


def close_session(session) -> None:
    session.close()


def update_session_headers(
    session: object, headers: Union[str, object]
) -> object:
    if utils.is_str(headers):
        headers = utils.from_json(headers)
    session.headers.update(headers)
    return session.headers


def get_session_headers(session: object) -> object:
    return session.headers


class RestClient:
    """REST client based on requests library."""

    def __init__(
        self,
        base_url: str = "",
        default_timeout: Union[int, str, None] = REQUESTS_TIMEOUT,
    ) -> None:
        self._base_url = base_url
        if default_timeout is None:
            self.default_timeout = None
        else:
            self.default_timeout = utils.to_int(default_timeout)

    def base_url(self, url: str) -> str:
        if not re.match(r"^http.+", url):
            url = self._base_url + url
        else:
            self._base_url = url
        return url

    def _requests(
        self,
        method: str,
        url: str,
        data: Optional[object] = None,
        headers: Union[str, object, None] = None,
        session: Optional[object] = None,
        expected_status: Union[list[int], int, None] = None,
        timeout: Union[int, str, None] = None,
        verbose: Union[bool, str] = False,
        console: Union[bool, str] = False,
    ) -> str:
        if timeout is None:
            timeout = self.default_timeout
        else:
            timeout = utils.to_int(timeout)

        url = self.base_url(url)
        if utils.is_json(data):
            data = utils.from_json(data)
        if utils.is_json(headers):
            headers = utils.from_json(headers)
        if session is None:
            fn = requests.request
        else:
            fn = session.request
        r = fn(method, url, json=data, headers=headers, timeout=timeout)
        if expected_status is not None:
            if utils.is_scalar(expected_status):
                expected_status = [expected_status]
            expected_status = utils.to_int(expected_status)
            if r.status_code not in expected_status:
                raise AssertionError(
                    f"Expected {expected_status} but received {r.status_code}"
                    + f"\n  from: {url} {data}"
                    + f"\n  content: {r.text}"
                )
        if utils.to_bool(verbose) is True:
            platform.debug_log(
                f"HTTP {method} {url}, data: {data}, timeout: {timeout}, "
                + f" status_code: {r.status_code}, content: {r.content}",
                console=utils.to_bool(console),
            )
        return r

    def get(self, *args, **kwargs) -> object:
        return self._requests("GET", *args, **kwargs)

    def post(self, *args, **kwargs) -> object:
        return self._requests("POST", *args, **kwargs)

    def put(self, *args, **kwargs) -> object:
        return self._requests("PUT", *args, **kwargs)

    def patch(self, *args, **kwargs) -> object:
        return self._requests("PATCH", *args, **kwargs)

    def delete(self, *args, **kwargs) -> object:
        return self._requests("DELETE", *args, **kwargs)
