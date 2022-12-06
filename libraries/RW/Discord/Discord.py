import json
import requests

class Discord:
    """
    Discord integration to send messages via webhook to channels.

    """
    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def send_message(self, webhook_url, message, timeout=30):
        """
        Send a message to a webhook-enabled Discord channel using the webhook URL.

        Examples:
        | RW.Discord.Send Message  |   https://discord.com/api/webhooks/...example...     |   Hello World!  | 
        | RW.Discord.Send Message  |   ${DISCORD_WEBHOOK_URL}     |   ${CHAT_MESSAGE}  | 

        Return Value:
        |   response: requests.response  |
        """
        message = {
            "content": f"{message}"}
        headers = {'Content-Type': 'application/json; charset=UTF-8'}
        rsp = requests.post(webhook_url, headers=headers, json=message, timeout=timeout)
        return rsp