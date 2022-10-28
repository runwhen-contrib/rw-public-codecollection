"""
Rocketchat keyword library
Scope: Global
"""
from email import header
import logging

from typing import Optional

import requests
from RW import platform
from rocketchat_API.rocketchat import RocketChat
from rocketchat_API.APIExceptions.RocketExceptions import RocketException

from RW.Utils import utils

# TODO: disambiguate classname from client package
# TODO: improve docstrings
class Rocketchat:
    """Rocketchat keyword library can be used to send messages to Rocketchat channels."""

    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def send_message(
        self,
        msg: str,
        channel: str,
        user: str,
        password: str,
        server: str,
        alias: str = "RunWhen",
    ) -> object:
        """
        Sends message to specified channel on a given RocketChat server.
        - ``msg`` determines the message sent.
        - ``channel`` rocketchat channel to send message to.
        - ``user`` rocketchat username to login as (not email).
        - ``password`` password of user.
        - ``server`` rocketchat server hostname URL, usually something like https://runwhen-dev.rocket.chat/.
        - ``alias`` sets alias of user, defaults to "RunWhen".
        Examples:
        | RW.Rocketchat.Send Message    | Hello world!   | example-channel  | example-user  | example-pass  | https://runwhen-dev.rocket.chat/  |
        Return Value:
        | Response string               |
        """
        client = RocketChat(user=user, password=password, server_url=server)
        rsp = client.chat_post_message(
            text=msg, channel=channel, alias=alias
        ).json()
        return rsp

    def incoming_webhook(
        self,
        webhook_url: platform.Secret,
        message: str,
        alias: str = "RunWhen Bot",
        timeout: int = 30,
    ) -> requests.Response:
        """_summary_

        Args:
            webhook_url (platform.Secret): _description_
            alias (str): _description_
            text (str): _description_
            timeout (int, optional): _description_. Defaults to 30.

        Returns:
            requests.Response: _description_
        """
        data: dict = {
            "alias": f"{alias}",
            "text": f"{message}",
        }
        headers = {"Content-Type": "application/json"}
        rsp: requests.Response = requests.post(
            url=webhook_url, headers=headers, json=data, timeout=timeout
        )
        return rsp
