from abc import ABC, abstractmethod

from RW.Chat.strategies.ChatProviderStrategy import ChatProviderStrategy
from RW.Discord import Discord

class DiscordChatProviderStrategy(ChatProviderStrategy):
    def send_message(self, message: str, **kwargs):
        self.client = Discord()
        rsp = self.client.send_message(self.webhook_url, message)
        return rsp