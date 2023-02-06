"""
Google Chat keyword library

Scope: Global
"""
import json
import requests

from RW import platform


class Chat:
    """
    Google Chat integration to send messages via webhook to channels.

    To allow a channel to receive a webhook follow: https://developers.google.com/chat/how-tos/webhooks
    """

    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def send_message(self, webhook_url: platform.Secret, message, timeout=30):
        """
        Send a message to a Google Chat channel using the webhook URL.

        Examples:
        | RW.GCP.Chat.Send Message  |   https://chat.googleapis.com/v1/spaces/...example...     |   Hello World!  |
        | RW.GCP.Chat.Send Message  |   ${GCP_CHAT_WEBHOOK}     |   ${CHAT_MESSAGE}  |

        Return Value:
        |   response: requests.response  |
        """
        message = {"text": f"{message}"}
        headers = {"Content-Type": "application/json; charset=UTF-8"}
        rsp = requests.post(webhook_url.value, headers=headers, json=message, timeout=timeout)
        return rsp
