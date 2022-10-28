"""
Opsgenie keyword library

Scope: Global
"""
import opsgenie_sdk
from opsgenie_sdk.rest import ApiException
from RW.Utils import utils


class Opsgenie:
    #TODO: refactor for new platform use
    """
    Opsgenie is a keyword library for integrating with the Opsgenie services.
    It can be used to send alerts to Opsgenie.
    """

    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def __init__(self) -> None:
        self.configuration = None

    def connect_to_opsgenie(self, token: str) -> None:
        """
        Authentication for Opsgenie. This step is required before performing any
        Opsgenie operations.
        Depending on the operation, you will need either the Opsgenie API Key
        or the Opsgenie Team Integration API Key.
        Examples:
        | Import User Variable | OPSGENIE_TEAM_INTEGRATION_API_KEY    |
        | Connect To Datadog   | ${OPSGENIE_TEAM_INTEGRATION_API_KEY} |
        """
        self.configuration = opsgenie_sdk.Configuration()
        self.configuration.api_key["Authorization"] = token

    def get_info(self, verbose: bool = False) -> object:
        """
        Get Opsgenie account information.
        For this operation, you will need the Opsgenie API Key.
        Examples:
        | Import User Variable | OPSGENIE_API_KEY     |
        | Connect To Datadog   | ${OPSGENIE_API_KEY}  |
        | ${res} =             | RW.Opsgenie.Get Info |
        Return Value:
        | opsgenie_sdk.GetAccountInfoResponse |
        """
        api_instance = opsgenie_sdk.AccountApi(
            opsgenie_sdk.ApiClient(self.configuration)
        )
        try:
            resp = api_instance.get_info()
            if verbose:
                utils.debug_log(resp, console=False)
            return resp
        except ApiException as e:
            utils.task_error(
                f"Exception when calling AccountApi->get_info: {e}"
            )

    def create_alert(
        self,
        summary: str,
        description: str,
        priority: str = "P5",
        verbose: bool = False,
    ) -> object:
        """
        Create an Opsgenie alert.
        For this operation, you will need the Opsgenie Team Integration API Key.
        Alert priority:
        | P1 | Critical      |
        | P2 | High          |
        | P3 | Moderate      |
        | P4 | Low           |
        | P5 | Informational |
        Examples:
        | Import User Variable | OPSGENIE_TEAM_INTEGRATION_API_KEY     | | | |
        | Connect To Datadog   | ${OPSGENIE_TEAM_INTEGRATION_API_KEY}  | | | |
        | ${res} =             | RW.Opsgenie.Create Alert | summary=backend-service is down | description=HTTP status code: 500 | priority=P2 |
        Return Value:
        | opsgenie_sdk.GetAccountInfoResponse |
        """
        api_instance = opsgenie_sdk.AlertApi(
            api_client=opsgenie_sdk.api_client.ApiClient(self.configuration)
        )
        body = opsgenie_sdk.CreateAlertPayload(
            message=summary,
            description=description,
            priority=priority,
        )

        try:
            resp = api_instance.create_alert(body)
            if verbose:
                utils.debug_log(resp, console=False)
            return resp
        except ApiException as e:
            utils.task_error(
                f"Exception when calling AlertApi->create_alert: {e}"
            )
