*** Settings ***
Metadata          Author    Jonathan Funk
Documentation     Check the status of an Uptime.com component for a given site.
...               It compares the operational state of the component with the list of allowed states, resulting in a 1 when acceptable, and 0 when not.
Force Tags        Uptime.Com    Uptime    Component    Statuspage    Operational    Up
Library           RW.Core
Library           RW.Uptime.StatusPage
Suite Setup       Suite Initialization

*** Keywords ***
Suite Initialization
    ${UPTIME_TOKEN}=    RW.Core.Import Secret    UPTIME_TOKEN
    ${UPTIME_COMPONENT_URL}=    RW.Core.Import User Variable    UPTIME_COMPONENT_URL
    ...    type=string
    ...    description=What URL to retrieve health data from.
    ...    pattern=\w*
    ...    default=https://uptime.com/api/v1/statuspages/{page_id}/components/{component_id}/
    ...    example=https://uptime.com/api/v1/statuspages/{page_id}/components/{component_id}/
    RW.Core.Import User Variable    ACCEPTABLE_STATES
    ...    type=string
    ...    description=What operational state the component can be in. eg: operational, undergoing planned maintenance, etc. Accepts a CSV.
    ...    pattern=\w*
    ...    default=operational,under-maintenance
    ...    example=operational,under-maintenance
    Set Suite Variable    ${UPTIME_TOKEN}    ${UPTIME_TOKEN}
    Set Suite Variable    ${ACCEPTABLE_STATES}    ${ACCEPTABLE_STATES}
    Set Suite Variable    ${UPTIME_COMPONENT_URL}    ${UPTIME_COMPONENT_URL}

*** Tasks ***
Check If Vault Endpoint Is Healthy
    ${rsp}=    RW.Uptime.StatusPage.Get Component Status    auth_token=${UPTIME_TOKEN}    url=${UPTIME_COMPONENT_URL}
    ${status}=    RW.Uptime.StatusPage.Validate Component Status    status_data=${rsp}    allowed_status=${ACCEPTABLE_STATES}
    ${score}=    Evaluate    1 if ${status} is True else 0
    RW.Core.Push Metric    ${score}
