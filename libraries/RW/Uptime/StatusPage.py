import requests
from RW import platform


class StatusPage:
    """Used to fetch and validate data/metrics from a Uptime.com status page and its components.

    Returns:
        _type_: None
    """

    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def get_component_status(
        self, auth_token: platform.Secret, url: str, timeout: int = 30
    ) -> dict:
        """Returns the current operational state of a component on a status page. Refer to https://uptime.com/api/v1/docs/#/statuspages/get_component_detail for docs.

        Args:
            auth_token (platform.Secret): A Platform Secret object containing the auth token for the Uptime status page.
            url (str): A URL pointing to the status page's component, eg: https://uptime.com/api/v1/statuspages/{status_page_id}/components/{component_id}/
            timeout (int, optional): request timeout duration. Defaults to 30.

        Returns:
            dict: a dictionary containing the current operational state converted from json contents.
        """
        headers: dict = {"Authorization": f"token {auth_token.value}"}
        rsp: requests.Response = requests.get(
            url=url, headers=headers, timeout=timeout
        )
        return rsp.json()

    def validate_component_status(
        self, status_data: dict, allowed_status="operational,under-maintenance"
    ) -> bool:
        """Given a component status payload, check if it's within the allowed statuses (operational, planned maintenance, etc)
        returning True if it is, or false if not.

        Args:
            status_data (dict): A dictionary converted from the json contents of a response. Typically from get_component_status.
            allowed_status (str, optional): a CSV of allowed states. Defaults to "operational,under-maintenance".

        Returns:
            bool: whether the component is in an acceptable operational state or not.
        """
        allowed_status: list = allowed_status.split(",")
        if status_data["status"] in allowed_status:
            return True
        return False
