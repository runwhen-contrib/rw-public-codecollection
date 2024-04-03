*** Settings ***
Metadata          Author    Jonathan Funk
Metadata          Display Name    HahiCorp Vault Health
Metadata          Supports    vault 
Documentation     Check the health of a Vault server.
...               The response code is used to determine if the service is healthy, resulting in a metric of 1 if it is, or 0 if not.
Force Tags        HashiCorp    Vault    health    HTTP
Library           RW.Core
Library           RW.HashiCorp.Vault

*** Tasks ***
Check If Vault Endpoint Is Healthy
    ${VAULT_HEALTH_URL}=    RW.Core.Import User Variable    VAULT_HEALTH_URL
    ...    type=string
    ...    description=What URL to retrieve health data from.
    ...    pattern=\w*
    ...    default=https://my-vault/v1/sys/health
    ...    example=https://my-vault/v1/sys/health
    ${rsp}=    RW.HashiCorp.Vault.Check Health    url=${VAULT_HEALTH_URL}
    ${score}=    Evaluate    1 if ${rsp} is True else 0
    RW.Core.Push Metric    ${score}
