from abc import ABC, abstractmethod

class GetClientStrategy(ABC):
    def __init__(self, **kwargs):
        self.client = None
        self.client_config_cache = {}
        for k, v in kwargs.items():
            setattr(self, k, v)

    @abstractmethod
    def get_client(self, service_name: str, **kwargs):
        pass
