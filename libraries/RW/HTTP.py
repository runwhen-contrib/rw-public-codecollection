"""
HTTP keyword library

Scope: Global
"""
from typing import Optional
from RW import platform, restclient
from RW.Utils import utils


class HTTP:
    #TODO: refactor for new platform use
    #TODO: move to dedicated module
    #TODO: add robot tests
    #TODO: simplify interfaces
    """HTTP keyword library defines HTTP/REST-related keywords."""

    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def __init__(self) -> None:
        pass

    def create_session(self, *args, **kwargs) -> object:
        """
        Create a simple HTTP session.
        Return Value:
        | Session handle |
        """
        return restclient.create_session(*args, **kwargs)

    def create_authenticated_session(
        self,
        url=None,
        user=None,
        password=None,
        token=None,
        headers=None,
        soft_error=False,
        verbose=False,
    ) -> object:
        """
        Create an HTTP authenticated session.
        - Use Bearer token if provided
        - Or use login URL, user name, and password if provided
        - Or use custom fields in HTTP headers
        If ``headers`` (HTTP headers) is not specified, use ``{"Accept": "application/json"}``.
        Examples:
        | ${session} = | Create Authenticated Session | ${SERVICE_ENDPOINT}/api/v3/token/ | ${USER_NAME} | ${PASSWORD} |
        | ${res} =     | POST | ${SERVICE_ENDPOINT}/api/v3/workspaces/${WORKSPACE_NAME} | body=${body} | session=${session} |
        Return Value:
        | Session handle |
        """
        verbose = utils.to_bool(verbose)
        if headers is None:
            headers = {"Accept": "application/json"}
        if token is not None:
            headers["Authorization"] = f"Bearer {token}"
        if verbose is True:
            platform.debug_log(f"headers: {utils.prettify(headers)}")
        session = self.create_session(headers)

        if url is not None and user is not None:
            # Authentication using user name/password.
            res = self.post(
                url,
                data={"username": user, "password": password},
                session=session,
            )
            # if verbose is True:
            #     platform.debug_log(utils.prettify(res.json()))
            platform.debug_log(f"res.status_code: {res.status_code}")
            if res.status_code not in [200]:
                if soft_error is True:
                    platform.debug_log("create_authenticated_session: ")
                raise platform.TaskError(
                    f"Authentication error - status code: {res.status_code}, reason: {res.reason}"
                )
            token = res.json()["access"]
            self.update_session_headers(
                session,
                {
                    "Authorization": f"Bearer {token}",
                    "Content-Type": "application/json",
                },
            )
        return session

    def close_session(self, *args, **kwargs) -> None:
        """
        Close the HTTP session.
        Examples:
        | Close Session | ${session} |
        """
        restclient.close_session(*args, **kwargs)

    def update_session_headers(self, *args, **kwargs) -> object:
        """
        Update the HTTP session headers.
        Examples:
        | Update Session Headers | ${session} | {"Content-Type": "application/json"} |
        Return Value:
        | Updated session headrs |
        """
        return restclient.update_session_headers(*args, **kwargs)

    def get_session_headers(self, *args, **kwargs) -> object:
        """
        Get the HTTP session headers
        Examples:
        | Get Session Headers | ${session} |
        Return Value:
        | Updated session headrs |
        """
        return restclient.get_session_headers(*args, **kwargs)

    def get(self, *args, **kwargs) -> object:
        """
        HTTP GET
        Arguments:
        | url             | URL string |
        | body            | Optional - Typically required for POST, PUT, PATCH |
        | headers         | Optional - HTTP headers |
        | session         | Optional - HTTP session |
        | expected_status | Optional - Integer value representing the expected error status, e.g., 200 for OK. |
        | timeout         | Optional - HTTP timeout (default is 45 seconds) |
        Examples:
        | ${res} = | GET | ${SERVICES_ENDPOINT}/api/v1/health | expect_status=200 |
        Return Value:
        | Requests result |
        """
        latency, res = utils.latency(
            restclient.RestClient().get,
            *args,
            **kwargs,
            latency_params=[3, "s"],
        )
        res.latency = latency
        return res

    def post(self, *args, **kwargs) -> object:
        """
        HTTP POST
        Examples:
        | ${res} = | POST | ${SERVICE_ENDPOINT}/api/v1/resource | body=${body} | session=${session} | expect_status=201 |
        Return Value:
        | Requests result |
        See `Get` for more details.
        """
        latency, res = utils.latency(
            restclient.RestClient().post,
            *args,
            **kwargs,
            latency_params=[3, "s"],
        )
        res.latency = latency
        return res

    def put(self, *args, **kwargs) -> object:
        """
        HTTP PUT
        Examples:
        | ${res} = | PUT | ${SERVICE_ENDPOINT}/api/v1/resource/123 | body=${body} | session=${session} |
        Return Value:
        | Requests result |
        See `Get` for more details.
        """
        latency, res = utils.latency(
            restclient.RestClient().put,
            *args,
            **kwargs,
            latency_params=[3, "s"],
        )
        res.latency = latency
        return res

    def patch(self, *args, **kwargs) -> object:
        """
        HTTP PATCH
        Examples:
        | ${res} = | PATCH | ${SERVICE_ENDPOINT}/api/v1/resource/123 | body=${body} | session=${session} |
        Return Value:
        | Requests result |
        See `Get` for more details.
        """
        latency, res = utils.latency(
            restclient.RestClient().patch,
            *args,
            **kwargs,
            latency_params=[3, "s"],
        )
        res.latency = latency
        return res

    def delete(self, *args, **kwargs) -> object:
        """
        HTTP PATCH
        Examples:
        | ${res} = | DELETE | ${SERVICE_ENDPOINT}/api/v1/resource/123 | session=${session} |
        Return Value:
        | Requests result |
        See `Get` for more details.
        """
        latency, res = utils.latency(
            restclient.RestClient().delete,
            *args,
            **kwargs,
            latency_params=[3, "s"],
        )
        res.latency = latency
        return res
