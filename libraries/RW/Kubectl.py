"""
Kubectl keyword library

Scope: Global
"""
import re
from typing import Optional, Union
import requests
from RW import restclient
from RW import platform
from RW.Utils import utils


class Kubectl:
    #TODO: remove and incorporate into K8s v3 rework
    """
    Kubectl keyword library can be used to interact with Kubernetes clusters via kubectl location service.
    """

    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def __init__(self):
        try:
            self.kubectl_service_endpoint = platform.import_platform_variable(
                "RW_KUBECTL_SERVICE_ENDPOINT"
            )
        except ImportError:
            self.kubectl_service_endpoint = (
                "http://kubectl-service.location.svc.cluster.local/kubectl/"
            )
        self._kubeconfig = None

    def set_kubeconfig(self, kubeconfig: str):
        self._kubeconfig = kubeconfig

    def kubectl(
        self,
        *args,
        expected_status=None,
    ) -> object:
        """
        Run kubectl command.

        """
        if self._kubeconfig is None:
            raise Exception(
                "Kubeconfig needs to be set before running kubectl commands"
            )
        options = " ".join(args)
        body = {"options": str(options), "kubeconfig": str(self._kubeconfig)}
        rsp = requests.post(self.kubectl_service_endpoint, json=body)
        content = utils.from_json(rsp.content)
        if expected_status is not None:
            if utils.is_scalar(expected_status):
                expected_status = [expected_status]
            expected_status = utils.to_int(expected_status)
            if content["exit_code"] not in expected_status:
                raise AssertionError(
                    f"Expected exit code {expected_status} but received"
                    + f" {content['exit_code']}"
                    + f"\n  command: {content['command']}"
                    + f"\n  stdout: {content['stdout']}"
                    + f"\n  stderr: {content['stderr']}"
                )
        return content

    def stdout_to_lists(self, stdout):
        stdout_lists = []
        for line in stdout.splitlines():
            stdout_lists.append(line.split())
        return stdout_lists

    def get_kubectl_list_column(self, stdout_lists, index: int):
        """
        Helper function to return a column as a list from the stdout lists of a kubectl command
        """
        result_column = []
        for row in stdout_lists:
            result_column.append(row[index])
        return result_column

    def remove_units(
        self,
        data_points,
    ):
        """
        Iterates over list and removes units
        - ``data_points`` list of string values containing numerical value substrings

        Examples:
        | RW.Kubectl.Remove Units  |   ${str_list}
        Return Value:
        | List of floats |
        """
        cleaned = []
        for d in data_points:
            numerical = float(
                "".join(i for i in d if i.isdigit() or i in [".", "-"])
            )
            cleaned.append(numerical)
        return cleaned
