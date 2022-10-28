*** Settings ***
Library           RW.HashiCorp.Vault
Library           RW.platform
Library           RW.Core
Library           OperatingSystem
Suite Setup       Suite Initialization

*** Keywords ***
Suite Initialization
    Set Suite Variable    ${VAULT_URL}    %{VAULT_URL}

*** Tasks ***
Health Check Vault
    ${rsp}=    RW.HashiCorp.Vault.Get Health    url=${VAULT_URL}
    ${vault_health}=    Set Variable    ${rsp}
    ${rsp}=    RW.HashiCorp.Vault.Check Health    url=${VAULT_URL}
    ${status}=    Set Variable    ${rsp}
