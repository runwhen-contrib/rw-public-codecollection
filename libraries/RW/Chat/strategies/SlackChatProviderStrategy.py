from abc import ABC, abstractmethod

from RW.Chat.strategies.ChatProviderStrategy import ChatProviderStrategy
from RW.Slack import Slack


class SlackChatProviderStrategy(ChatProviderStrategy):
    def send_message(self, message: str, **kwargs):
        self.client = Slack()
        rsp = self.client.post_message(self.token, self.channel, message)
        return rsp
