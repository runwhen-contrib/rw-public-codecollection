import logging
import boto3
from RW.AWS.strategies.GetClientStrategy import GetClientStrategy

# silence verbose logging
logging.getLogger('boto3').setLevel(logging.CRITICAL)
logging.getLogger('botocore').setLevel(logging.CRITICAL)
logging.getLogger('s3transfer').setLevel(logging.CRITICAL)
logging.getLogger('urllib3').setLevel(logging.CRITICAL)

class UserGetClientStrategy(GetClientStrategy):
    def get_client(self, service_name: str, **kwargs):
        client_config = {
            "service_name": service_name,
            **kwargs
        }
        if self.client and self.client_config_cache == client_config:
            return self.client
        else:
            self.client_config_cache = client_config
            self.client = None # clear cache
            self.client = boto3.client(
                service_name=service_name,
                region_name=self.region_name,
                aws_access_key_id=self.aws_access_key_id,
                aws_secret_access_key=self.aws_secret_access_key,
                **kwargs,
            )
            return self.client