"""
RunWhen Chat keyword library

Scope: Global
"""
from enum import Enum

from RW.Chat.strategies.ChatProviderStrategy import ChatProviderStrategy
from RW.Chat.strategies.RocketChatProviderStrategy import (
    RocketChatProviderStrategy,
)
from RW.Chat.strategies.SlackChatProviderStrategy import (
    SlackChatProviderStrategy,
)
from RW.Chat.strategies.GoogleChatProviderStrategy import (
    GoogleChatProviderStrategy,
)
from RW.Chat.strategies.DiscordChatProviderStrategy import DiscordChatProviderStrategy
from RW.RunWhen.Papi import Papi


class Chat:
    """
    RunWhen Chat keyword library for integrating with various chat systems like Slack and Discord.
    """

    class ChatProvider(Enum):
        GOOGLE_CHAT = "GoogleChat"
        ROCKET_CHAT = "RocketChat"
        SLACK = "Slack"
        MICROSOFT_TEAMS = "MicrosoftTeams"
        DISCORD = "Discord"
        PAGER_DUTY = "PagerDuty"
        ALERT_MANAGER = "AlertManager"

    class ReportOption(Enum):
        YES = "Yes"
        NO = "No"

    class RunsessionLinkOption(Enum):
        YES = "Yes"
        NO = "No"

    def __init__(self):
        self._chat_provider_strategy: ChatProviderStrategy = None
        self._papi: Papi = Papi()

    def send_message(self, **kwargs):
        """
        Sends a message to a chat provider using the available authentication configuration.

        Examples:
        | RW.Chat.Send Message  |     chat_provider=Slack     |     channel=#mychannel  |   myslacktoken    |   my helpful message!     |

        Return Value:
        |   Response  |
        """
        message = kwargs.get("message", None)
        service = kwargs.get("chat_provider", None)
        include_reports = kwargs.get("include_reports", None)
        include_runsession_link = kwargs.get("include_runsession_link", None)
        if not message:
            raise ValueError("Message was not properly set")
        if not service:
            raise ValueError("A service strategy was not selected")
        if not include_reports:
            raise ValueError(
                "Did not select whether or not to include reports in the message"
            )
        if not include_reports:
            raise ValueError(
                "Did not select whether or not to include a runsession link"
            )

        if include_runsession_link == Chat.RunsessionLinkOption.YES.value:
            self._papi.authenticate()
            runsession_link = self._papi.get_runsession_url()
            if runsession_link:
                message = f"{runsession_link}\n{message}"

        if include_reports == Chat.ReportOption.YES.value:
            self._papi.authenticate()
            reports = self._papi.get_runsession_report()
            if reports:
                message = f"{message}\n{reports}"

        if service and service == Chat.ChatProvider.SLACK.value:
            self._chat_provider_strategy = SlackChatProviderStrategy(**kwargs)
        elif service and service == Chat.ChatProvider.DISCORD.value:
            self._chat_provider_strategy = DiscordChatProviderStrategy(**kwargs)
        elif service and service == Chat.ChatProvider.GOOGLE_CHAT.value:
            self._chat_provider_strategy = GoogleChatProviderStrategy(**kwargs)
        elif service and service == Chat.ChatProvider.ROCKET_CHAT.value:
            self._chat_provider_strategy = RocketChatProviderStrategy(**kwargs)

        if not self._chat_provider_strategy:
            raise ValueError(
                "A valid service strategy could not be set during setup"
            )
        rsp = self._chat_provider_strategy.send_message(message)
        return rsp
