import logging
import boto3
from RW.AWS.strategies.GetClientStrategy import GetClientStrategy

# silence verbose logging
logging.getLogger('boto3').setLevel(logging.CRITICAL)
logging.getLogger('botocore').setLevel(logging.CRITICAL)
logging.getLogger('s3transfer').setLevel(logging.CRITICAL)
logging.getLogger('urllib3').setLevel(logging.CRITICAL)

class RoleGetClientStrategy(GetClientStrategy):
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
            session_token_service = boto3.client(
                "sts",
                aws_access_key_id=self.aws_access_key_id,
                aws_secret_access_key=self.aws_secret_access_key,
                **kwargs,
            )
            session_credentials = session_token_service.assume_role(
                RoleArn=self.role_arn, RoleSessionName=self.session_name
            )
            session_id = session_credentials["Credentials"]["AccessKeyId"]
            session_key = session_credentials["Credentials"]["SecretAccessKey"]
            session_token = session_credentials["Credentials"]["SessionToken"]
            self.client = boto3.client(
                service_name=service_name,
                region_name=self.region_name,
                aws_access_key_id=session_id,
                aws_secret_access_key=session_key,
                aws_session_token=session_token,
                **kwargs,
            )
            return self.client
