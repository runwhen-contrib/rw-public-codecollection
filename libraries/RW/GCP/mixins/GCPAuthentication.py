import json
import urllib
import re
from dataclasses import dataclass
from google.oauth2 import service_account
from google.cloud import monitoring_v3, logging
from google.protobuf.json_format import MessageToDict
from typing import Optional


class GCPAuthentication:
    def __init__(self):
        self._credentials = None

    def authenticate(self, service_account_json: str):
        """
        Sets the google service account credentials from a json string.
        - ``service_account_json`` the json string from a google account credentials file.

        Examples:
        | RW.GCP.OpsSuite.Set Opssuite Credentials  |   ${opssuite_sa_creds}
        """
        if not service_account_json:
            raise ValueError(f"service_account_json is empty")
        sa = json.loads(service_account_json)
        self._credentials = service_account.Credentials.from_service_account_info(sa)

    def get_credentials(self) -> object:
        """
        Return the credentials.
        :return: The credentials
        """
        return self._credentials


