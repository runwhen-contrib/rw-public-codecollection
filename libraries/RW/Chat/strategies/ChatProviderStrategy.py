from abc import ABC, abstractmethod

class ChatProviderStrategy(ABC):
    def __init__(self, **kwargs):
        for k, v in kwargs.items():
            setattr(self, k, v)
        self.client = None

    @abstractmethod
    def send_message(self, message: str, **kwargs):
        pass
