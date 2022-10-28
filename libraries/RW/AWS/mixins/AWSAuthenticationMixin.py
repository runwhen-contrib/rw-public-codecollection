import boto3

from enum import Enum
from abc import ABC

from RW.AWS.strategies.GetClientStrategy import GetClientStrategy
from RW.AWS.strategies.UserGetClientStrategy import UserGetClientStrategy
from RW.AWS.strategies.RoleGetClientStrategy import RoleGetClientStrategy
from RW import platform

class AWSAuthenticationMixin(ABC):
    """
    Mixin abstract base class for abstracting authentication workflow from AWS keywords. Acts as the context in a strategy pattern.
    """
    class AuthModes(Enum):
        WithRole = "Role"
        WithUser = "User"

    def __init__(self):
        self.aws_access_key_id = None
        self.aws_secret_access_key = None
        self.region_name = None
        self.role_arn = None
        self.session_name = "sli-automation"
        self._auth_mode = None
        self._get_client_strategy : GetClientStrategy = None
        
    def set_aws_keys(
        self,
        aws_access_key_id: platform.Secret,
        aws_secret_access_key: platform.Secret,
    ):
        self.aws_access_key_id = aws_access_key_id.value
        self.aws_secret_access_key = aws_secret_access_key.value

    def set_get_client_strategy(self, strategy: GetClientStrategy):
        self._get_client_strategy = strategy

    def authenticate(self, aws_access_key_id: platform.Secret, aws_secret_access_key: platform.Secret, region_name, role_arn: platform.Secret=None, auth_mode="User", **kwargs):
        """
        Omnibus method which equips the authentication strategy for the AWS keyword. To be used by ``get_client``

        ``Note``: * refers to the inheriting keyword class using the mixin.

        Examples:
        |   RW.AWS.*.Authenticate   |   ${AWS_ACCESS_KEY_ID}    |   ${AWS_SECRET_ACCESS_KEY}    |   ${AWS_REGION}   |   role    |   ${AWS_ROLE_ASSUME_ARN}  |
        """
        self.set_aws_keys(aws_access_key_id, aws_secret_access_key)
        self.region_name = region_name
        # role_arn = kwargs.get("role_arn", None)
        if role_arn and not isinstance(role_arn, platform.Secret):
            raise ValueError(f"role_arn {role_arn} provided but not as a platform secret")
        if auth_mode == AWSAuthenticationMixin.AuthModes.WithRole.value and role_arn:
            self._auth_mode = AWSAuthenticationMixin.AuthModes.WithRole
            self.role_arn = role_arn.value
            self.set_get_client_strategy(
                RoleGetClientStrategy(
                    aws_access_key_id=self.aws_access_key_id,
                    aws_secret_access_key=self.aws_secret_access_key,
                    region_name=self.region_name,
                    session_name=self.session_name,
                    role_arn=self.role_arn,
                    **kwargs)
            )
        # else assume AWSAuthenticationMixin.AuthModes.WithUser.value
        else:
            self._auth_mode = AWSAuthenticationMixin.AuthModes.WithUser
            self.set_get_client_strategy(
                UserGetClientStrategy(
                    aws_access_key_id=self.aws_access_key_id,
                    aws_secret_access_key=self.aws_secret_access_key,
                    region_name=self.region_name,
                    **kwargs
                )
            )
        self._validate_authentication()

    def get_client(self, service_name: str, **kwargs):
        self._validate_authentication()
        # the client state is handled within the strategy and not the mixin
        client = self._get_client_strategy.get_client(service_name, **kwargs)
        if client is None:
            raise ValueError("A valid authentication mode was not set and so a client could not be provided")
        return client
    
    def _validate_authentication(self):
        if not self.aws_access_key_id or not self.aws_secret_access_key or not self.region_name:
            raise ValueError("AWS access keys or region were not set, did you provide them via authenticate()?")
        elif not self._auth_mode:
            raise ValueError("The auth mode was not set, did you provide it in authenticate()?")
        elif self._auth_mode == AWSAuthenticationMixin.AuthModes.WithRole and not self.role_arn:
            raise ValueError("The auth mode was set to 'role' but you did not provide a role arn to assume in authenticate()")
        elif not self._get_client_strategy:
            raise ValueError("A valid client strategy was never set during authenticate()")
