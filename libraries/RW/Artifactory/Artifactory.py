import requests
from RW.K8s import K8s
from benedict import benedict


class Artifactory:
    """_summary_

    Returns:
        _type_: _description_
    """
    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    HEALTHY = "HEALTHY"
    UNHEALTHY = "UNHEALTHY"

    def __init__(self):
        self._k8s = K8s()

    def get_health(self, url: str) -> dict:
        """_summary_

        Args:
            url (str): _description_

        Returns:
            dict: _description_
        """
        rsp = requests.get(url=url, timeout=30)
        return rsp.json()

    def validate_health(self, health_data: dict) -> bool:
        """_summary_

        Args:
            health_data (dict): _description_

        Returns:
            bool: _description_
        """
        health_data: benedict = benedict(health_data)
        if "router.state" not in health_data:
            return False
        if health_data["router.state"] != Artifactory.HEALTHY:
            return False
        if "services" in health_data:
            services: list[dict] = health_data["services"]
            for service in services:
                if service["state"] != Artifactory.HEALTHY:
                    return False
        return True
