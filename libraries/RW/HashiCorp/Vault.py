"""
HashiCorp Vault keyword library

Scope: Global
"""

import requests


class Vault:
    #TODO: update docstrings
    """
    HashiCorp Vault keyword library
    """

    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def get_health(self, url: str) -> dict:
        """_summary_

        Args:
            url (str): _description_

        Returns:
            dict: _description_
        """
        rsp: requests.Response = requests.get(url=url, timeout=30)
        return rsp.json()

    def check_health(self, url: str) -> bool:
        """_summary_

        Args:
            url (str): _description_

        Returns:
            dict: _description_
        """
        rsp: requests.Response = requests.get(url=url, timeout=30)
        if rsp.status_code in [200, 429]:
            return True
        return False
