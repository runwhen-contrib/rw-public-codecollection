from abc import ABC, abstractmethod

from RW.Chat.strategies.ChatProviderStrategy import ChatProviderStrategy
from RW.Rocketchat import Rocketchat


class RocketChatProviderStrategy(ChatProviderStrategy):
    def send_message(self, message: str, **kwargs):
        self.client = Rocketchat()
        rsp = self.client.incoming_webhook(
            webhook_url=self.webhook_url, message=message
        )
        return rsp
