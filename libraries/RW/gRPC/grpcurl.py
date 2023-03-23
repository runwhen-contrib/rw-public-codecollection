import logging
from RW import platform, Utils

logger = logging.getLogger(__name__)


class gRPCurl:
    """
    A keyword set for running dynamic gRPC calls against gRPC services using the gRPCurl
    """

    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    @staticmethod
    def grpcurl_unary(
        cmd: str,
        target_service: platform.Service,
        optional_headers: platform.Secret = None,
        # TODO: support proto file sets
        # optional_proto_file=None,
    ):
        return gRPCurl.run_grpcurl(cmd, target_service, optional_headers)

    @staticmethod
    def run_grpcurl(
        cmd: str,
        target_service: platform.Service,
        optional_headers: platform.Secret = None,
    ):
        """Robot Keyword to manipulate gRPC curl before passing to rwplatform.execute_shell_command."""
        # TODO: test changes on curl-generic
        cmd = Utils.quote_curl(cmd)  # handle \" before inserted into eval
        optional_headers = Utils.secret_to_curl_headers(optional_headers=optional_headers, default_headers="{}")
        grpcurl_str: str = Utils.create_curl(cmd=cmd, optional_headers=optional_headers)
        request_optional_headers = platform.ShellServiceRequestSecret(optional_headers)
        request_secrets = [optional_headers] if optional_headers.value else None
        rsp = platform.execute_shell_command(cmd=grpcurl_str, service=target_service, request_secrets=request_secrets)
        if rsp.status != 200:
            raise ValueError(f"Received HTTP status of {rsp.status} from response {rsp}")
        if rsp.returncode > 0:
            raise ValueError(f"Recieved return code of {rsp.returncode} from response {rsp}")
        rsp = rsp.stdout
        return rsp
