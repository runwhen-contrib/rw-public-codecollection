"""
Pingdom keyword library

Scope: Global
"""
from typing import Union
from dataclasses import dataclass
from robot.libraries.BuiltIn import BuiltIn
from .Utils import utils
from RW.Utils.utils import Status


class Pingdom:
    #TODO: refactor for new platform use
    """
    Pingdom keyword library
    """

    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def __init__(self) -> None:
        self.session = None

        BuiltIn().import_library("RW.HTTP")
        self.rw_http = BuiltIn().get_library_instance("RW.HTTP")

        self.pingdom_url = utils.import_user_variable("PINGDOM_URL")
        self.pingdom_api_key = utils.import_user_variable("PINGDOM_API_KEY")

        self.session = self.rw_http.create_authenticated_session(
            token=self.pingdom_api_key
        )

    def __exit__(self, exc_type, exc_value, traceback):
        if self.session is not None:
            self.rw_http.close_session(self.session)

    def get_health_status(
        self,
        verbose: Union[str, bool] = False,
    ) -> None:
        """
        TBD
        """
        verbose = utils.to_bool(verbose)
        r = self.rw_http.get(f"{self.ping_url}/api/health")
        if verbose is True:
            platform.debug_log(r)

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
