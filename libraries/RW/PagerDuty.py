"""
PagerDuty keyword library

Scope: Global
"""
from pdpyras import APISession
from typing import Optional
from RW.Utils import utils


class PagerDuty:
    #TODO: refactor for new platform use
    """
    PagerDuty keyword library can be used to create new incident in PagerDuty.
    """

    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def __init__(self, api_token: Optional[str] = None) -> None:
        self.api_token = api_token

    def set_api_token(self, api_token=str) -> str:
        """
        Set the PagerDuty API Token. If the token is set then subsequent calls to
        PagerDuty keywords such as `Create Incident` don't need to specify the token.
        Examples:
        | Import User Variable       | PAGERDUTY_API_TOKEN    |
        | RW.PagerDuty.Set API Token | ${PAGERDUTY_API_TOKEN} |
        """
        self.api_token = api_token

    def _get_api_token(self) -> str:
        """
        Return the PagerDuty API Token which was previously set using `Set API Token`.
        Examples:
        | ${pd_token} = | RW.PagerDuty.Get API Token |
        Return Value:
        | PagerDuty token |
        """
        if self.api_token is None:
            raise core.TaskError("PagerDuty: API token is not defined.")
        return self.api_token

    def get_user_id(
        self,
        user_name: str,
        api_token: Optional[str] = None,
    ) -> str:
        """
        Get the user ID for the given PagerDuty user.
        Examples:
        | ${pd_user_id} = | RW.PagerDuty.Get User ID | vui |
        Return Value:
        | PagerDuty User ID |
        """
        if api_token is None:
            api_token = self._get_api_token()
        session = APISession(api_token)
        for user in session.iter_all("users"):
            if user_name == user["name"]:
                platform.debug_log(
                    f"PagerDuty: Found user '{user['name']}',"
                    f" ID: {user['id']}, email: {user['email']}",
                    console=False,
                )
                return user["id"]
        raise core.TaskError(
            f"PagerDuty: Cannot find user ID for '{user_name}'."
        )

    def get_service_id(
        self,
        service_name: str,
        api_token: Optional[str] = None,
    ) -> str:
        """
        Get the Service ID for the given PagerDuty service name.
        Examples:
        | ${pd_service_id} = | RW.PagerDuty.Get Service ID | app-a |
        Return Value:
        | PagerDuty User ID |
        """
        if api_token is None:
            api_token = self._get_api_token()
        session = APISession(api_token)
        for service in session.iter_all("services"):
            if service_name == service["name"]:
                platform.debug_log(
                    f"PagerDuty: Found service '{service['name']}',"
                    f" ID: {service['id']},"
                    f" description: {service['description']}",
                    console=False,
                )
                return service["id"]
        raise core.TaskError(
            f"PagerDuty: Cannot find service ID for '{service_name}'."
        )

    def _create_incident(
        self,
        title: str,
        service_name: str,
        user_name: Optional[str] = None,
        api_token: Optional[str] = None,
    ) -> object:
        """
        Create PagerDuty incident.

        :return: Incident result
        """
        if api_token is None:
            api_token = self.api_token
        session = APISession(api_token)
        service_id: str = self.get_service_id(
            service_name, api_token=api_token
        )
        payload = {
            "type": "incident",
            "title": title,
            "service": {"id": service_id, "type": "service_reference"},
        }
        if user_name is not None:
            user_id: str = self.get_user_id(user_name, api_token=api_token)
            payload["assignments"] = [
                {"assignee": {"id": user_id, "type": "user_reference"}}
            ]
        pd_incident = session.rpost("incidents", json=payload)
        platform.debug_log(
            f"PagerDuty: Incident details: {pd_incident}", console=False
        )
        return pd_incident

    def create_incident(
        self,
        title: str,
        service_name: str,
        api_token: Optional[str] = None,
    ) -> object:
        """
        Create PagerDuty incident.

        Examples:
        | ${pd_incident} = | Create Incident | App server is down | app-a | api_token=${token} |
        Return Value:
        | PagerDuty ncident data |
        """
        return self._create_incident(
            title=title, service_name=service_name, api_token=api_token
        )

    def create_incident_and_assign_user(
        self,
        title: str,
        service_name: str,
        user_name: str,
        api_token: Optional[str] = None,
    ) -> object:
        """
        Create PagerDuty incident and assign a user to the incident.

        Examples:
        | ${pd_incident} = | Create Incident And Assign User | App server is down | app-a | user_name=vui | api_token=${token} |
        Return Value:
        | PagerDuty ncident data |
        """
        return self._create_incident(
            title=title,
            service_name=service_name,
            user_name=user_name,
            api_token=api_token,
        )
