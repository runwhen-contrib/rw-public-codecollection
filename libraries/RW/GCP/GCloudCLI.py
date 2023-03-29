import requests
import logging
import urllib
import json
import dateutil.parser
from RW import platform, Utils

logger = logging.getLogger(__name__)

ROBOT_LIBRARY_SCOPE = "GLOBAL"


def shell(
    cmd: str,
    target_service: platform.Service,
    gcp_credentials_json: platform.Secret,
    project_id: str = None,
) -> any:
    if not target_service:
        raise ValueError("A runwhen service was not provided for the gcloud cli command")
    if not gcp_credentials_json:
        raise ValueError("A service account credentials json was not provided")
    gcp_credentials_json_str = gcp_credentials_json.value
    if Utils.is_json(gcp_credentials_json_str):
        gcp_credentials_json_dict: dict = Utils.from_json(gcp_credentials_json_str)
        if not project_id:
            project_id = gcp_credentials_json_dict.get("project_id", None)
    if not project_id:
        raise ValueError("A project_id could not be found or was not provided")
    # activate the service account in ssapi
    cmd = f"gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS && {cmd}"
    logger.info(f"requesting command: {cmd}")
    logger.info(f"selected project_id: {project_id}")
    request_secrets: [platform.ShellServiceRequestSecret] = []
    request_secrets.append(platform.ShellServiceRequestSecret(gcp_credentials_json, as_file=True))
    env = {
        "GOOGLE_APPLICATION_CREDENTIALS": f"./{gcp_credentials_json.key}",
        "CLOUDSDK_CORE_PROJECT": f"{project_id}",
    }
    rsp = platform.execute_shell_command(cmd=cmd, service=target_service, request_secrets=request_secrets, env=env)
    if (rsp.status != 200 or rsp.returncode > 0) and rsp.stderr != "":
        raise ValueError(
            f"The shell service responded with HTTP: {rsp.status} RC: {rsp.returncode} and response: {rsp}"
        )
    logger.info(f"shell stdout: {rsp.stdout}")
    return rsp.stdout
