*** Settings ***
Library           RW.Uptime.StatusPage
Library           RW.platform
Library           RW.Core
Library           OperatingSystem
Suite Setup       Suite Initialization

*** Keywords ***
Suite Initialization
    Set Suite Variable    ${UPTIME_COMPONENT_URL}    %{UPTIME_COMPONENT_URL}
    ${UPTIME_TOKEN}=    Evaluate    RW.platform.Secret("uptime_token", """%{UPTIME_TOKEN}""")
    Set Suite Variable    ${UPTIME_TOKEN}    ${UPTIME_TOKEN}

*** Tasks ***
Check Component Status
    ${rsp}=    RW.Uptime.StatusPage.Get Component Status    auth_token=${UPTIME_TOKEN}    url=${UPTIME_COMPONENT_URL}
    ${component_status}=    Set Variable    ${rsp}
    ${status}=    RW.Uptime.StatusPage.Validate Component Status    status_data=${component_status}    allowed_status=operational,under-maintenance
    Log    ${status}
