"""
Grafana keyword library

Scope: Global
"""
from typing import Union
from dataclasses import dataclass
from robot.libraries.BuiltIn import BuiltIn
from RW.Utils import utils
from RW.Utils.utils import Status


class Grafana:
    #TODO: refactor for new platform use
    """
    Grafana is a keyword library for integrating with the Grafana Dashboard.
    You need to provide a Grafana URL and a Grafana API Key to use
    this library.
    The first step is to authenticate using `Grafana Create Session`.
    """

    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def __init__(self) -> None:
        self.session = None
        self.grafana_url = None
        self.grafana_api_key = None

    def grafana_create_session(self, url, api_key) -> None:
        """
        Authentication for Grafana. This step is required before performing any
        Grafana operations.
        Examples:
        | Import User Variable | GRAFANA_URL     | | |
        | Import User Variable | GRAFANA_API_KEY | | |
        | ${session} =         | Grafana Create Session | ${GRAFANA_URL} | ${GRAFANA_API_KEY} |
        Return Value:
        | Grafana session |
        See also: `Grafana Close Session`
        """
        BuiltIn().import_library("RW.HTTP")
        self.grafana_url = url
        self.grafana_api_key = api_key
        self.session = restclient.create_authenticated_session(
            self.grafana_url, token=self.grafana_api_key
        )
        return self.session

    def grafana_close_session(self):
        """
        Close down the Grafana session.
        Examples:
        | Grafana Close Session | ${session} |
        See also: `Grafana Create Session`
        """
        if self.session is not None:
            self.rw_http.close_session(self.session)

    def get_health_status(
        self,
        session: Optional[object] = None,
        verbose: Union[str, bool] = False,
    ) -> None:
        """
        Check Grafana health status.
        Examples:
        | Import User Variable  | GRAFANA_URL     | | |
        | Import User Variable  | GRAFANA_API_KEY | | |
        | ${session} =          | Grafana Create Session | ${GRAFANA_URL} | ${GRAFANA_API_KEY} |
        | ${health_status} =    | RW.Grafana.Get Health Status | ${session} | |
        | Grafana Close Session | ${session} | | |
        Return Value:
        | Grafana health data |
        """
        verbose = utils.to_bool(verbose)
        r = self.rw_http.get(f"{self.grafana_url}/api/health", session=session)
        if verbose is True:
            utils.debug_log(r)

        status: Status = Status.NOT_OK
        if r.status_code in [200] and r.json()["database"] == "ok":
            status = Status.OK

        @dataclass
        class Result:
            original_content: object
            content: dict
            status_code: int = r.status_code
            reason: str = r.reason
            ok_status: Status = status
            ok: int = status.value

        return Result(r, r.json())
