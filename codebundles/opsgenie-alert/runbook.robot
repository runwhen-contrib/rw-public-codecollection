*** Settings ***
Documentation     Create an alert in Opsgenie.
Metadata          Display Name    OpsGenie Create Alert
Metadata          Supports     opsgenie
Metadata          Author        Vui Lee
Suite Setup       Runbook Setup
Library           RW.Core
Library           RW.Opsgenie
#TODO: Refactor for new platform use

*** Keywords ***
Runbook Setup
    RW.Core.Import User Variable    OPSGENIE_API_KEY
    RW.Core.Import User Variable    OPSGENIE_TEAM_INTEGRATION_API_KEY

*** Tasks ***
Get Opsgenie System Info
    [Documentation]    Get information about the Opsgenie system.
    #[Tags]    skipped
    RW.Opsgenie.Create Session    ${OPSGENIE_API_KEY}
    ${res} =    RW.Opsgenie.Get Info
    RW.Core.Info    Project name: ${res.data.name}
    RW.Core.Info    Opsgenie plan: ${res.data.plan.name}
    RW.Core.Info    User count: ${res.data.user_count}

Create An Alert
    [Documentation]    Create a new alert in Opsgenie.
    #[Tags]    skipped
    RW.Opsgenie.Create Session    ${OPSGENIE_TEAM_INTEGRATION_API_KEY}
    ${res} =    RW.Opsgenie.Create Alert
    ...    summary=backend-service is down
    ...    description=HTTP status code: 500
    ...    priority=P2
    RW.Core.Info    Request ID: ${res.request_id}
