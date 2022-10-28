"""
Slack keyword library

Scope: Global
"""
import logging
import slack_sdk
from slack_sdk.errors import SlackApiError
from typing import Optional

logging.basicConfig(level=logging.DEBUG)


class Slack:
    """Slack keyword library can be used to send messages to Slack."""

    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def post_message(
        self,
        token: str,
        channel: str,
        msg: str,
    ) -> object:
        """
        Post a message to a Slack channel.
        Examples:
        | Import User Variable  | SLACK_BOT_TOKEN |
        | RW.Slack.Post Message | token=${SLACK_BOT_TOKEN} | channel='#alerts' | message=Message XYZ |
        """
        client = slack_sdk.WebClient(token=token)
        try:
            client.chat_postMessage(channel=channel, text=f"{msg}")
        except SlackApiError as e:
            # You will get a SlackApiError if "ok" is False
            assert e.response["error"]  # str like 'invalid_auth', 'channel_not_found'
