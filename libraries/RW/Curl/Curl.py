import requests
import logging
import urllib
import json
import dateutil.parser
from RW import platform, Utils

logger = logging.getLogger(__name__)



class Curl:
    """
    A keyword library for housing general-purpose Curl keywords.
    """

    ROBOT_LIBRARY_SCOPE = "GLOBAL"
    def run_curl(
        self, cmd: str,
        optional_headers: platform.Secret,
        target_service: platform.Service
    ) -> dict:
        """Robot Keyword to manipulate curl before passing to rwplatform.execute_shell_command.

        """
        optional_headers = Utils.secret_to_curl_headers(optional_headers=optional_headers)
        curl_str: str = Utils.create_curl(cmd=cmd, optional_headers=optional_headers)
        request_optional_headers = platform.ShellServiceRequestSecret(optional_headers)
        rsp = platform.execute_shell_command(
            cmd=curl_str,
            service=target_service,
            request_secrets=[request_optional_headers]
        )
        if rsp.status != 200:
            raise ValueError(f"Received HTTP status of {rsp.status} from response {rsp}")
        if rsp.returncode > 0:
            raise ValueError(f"Recieved return code of {rsp.returncode} from response {rsp}")
        rsp = json.loads(rsp.stdout)
        return rsp
      