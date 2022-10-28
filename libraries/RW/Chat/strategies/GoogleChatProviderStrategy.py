from abc import ABC, abstractmethod

from RW.Chat.strategies.ChatProviderStrategy import ChatProviderStrategy
from RW.GCP.Chat import Chat

class GoogleChatProviderStrategy(ChatProviderStrategy):
    def send_message(self, message: str, **kwargs):
        self.client = Chat()
        rsp = self.client.send_message(self.webhook_url, message)
        return rsp