*** Settings ***
Documentation     Used internally to check the status of RunWhen Public API.
Library           RW.Core
Library           RW.RunWhen.Papi
Suite Setup       Suite Initialization

*** Tasks ***
Get All Recents Across Workspaces And Validate
    RW.RunWhen.Papi.Authenticate
    ${rsp}=    RW.RunWhen.Papi.Get All Recents In Workspace    30m    30s
    ${rsp}=    RW.RunWhen.Papi.Validate Recent Results    ${rsp}
    ${all_failures}=    Evaluate    len($rsp)
    Log    ${rsp}

*** Keywords ***
Suite Initialization
    RW.Core.Import User Variable    WORKSPACE_NAME
    Set Suite Variable    ${WORKSPACE_NAME}    ${WORKSPACE_NAME}
