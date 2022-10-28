*** Settings ***
Library           RW.RunWhen.Papi
Suite Setup       Suite Initialization

*** Tasks ***
Get Workspaces
    RW.RunWhen.Papi.Authenticate    ${RW_USERNAME}    ${RW_PASSWORD}
    ${rsp}=    RW.RunWhen.Papi.Get Workspaces
    Log    ${rsp}

Get SLXs
    RW.RunWhen.Papi.Authenticate    ${RW_USERNAME}    ${RW_PASSWORD}
    ${rsp}=    RW.RunWhen.Papi.Get Slxs    ${RW_E2E_WS}
    Log    ${rsp}

Get SLI
    RW.RunWhen.Papi.Authenticate    ${RW_USERNAME}    ${RW_PASSWORD}
    ${rsp}=    RW.RunWhen.Papi.Get Sli    ${RW_E2E_WS}    ${RW_E2E_DEFAULT_SLX}
    Log    ${rsp}

Get SLI Shortname
    RW.RunWhen.Papi.Authenticate    ${RW_USERNAME}    ${RW_PASSWORD}
    ${rsp}=    RW.RunWhen.Papi.Get Sli    ${RW_E2E_WS}    ${RW_E2E_DEFAULT_SLX}    name_only=True
    Log    ${rsp}

Get All SLIs In Workspace
    RW.RunWhen.Papi.Authenticate    ${RW_USERNAME}    ${RW_PASSWORD}
    ${rsp}=    RW.RunWhen.Papi.Get Slis    ${RW_E2E_WS}    names_only=True
    Log    ${rsp}

Get SLI Recent
    RW.RunWhen.Papi.Authenticate    ${RW_USERNAME}    ${RW_PASSWORD}
    ${rsp}=    RW.RunWhen.Papi.Get Sli Recent    ${RW_E2E_WS}    ${RW_E2E_DEFAULT_SLX}    30m    30s
    Log    ${rsp}

Get All SLI Recent Values In Workspace
    RW.RunWhen.Papi.Authenticate    ${RW_USERNAME}    ${RW_PASSWORD}
    ${rsp}=    RW.RunWhen.Papi.Get All Recents In Workspace    ${RW_E2E_WS}    30m    30s
    Log    ${rsp}

Get All SLI Recent Values And Validate In Workspace
    RW.RunWhen.Papi.Authenticate    ${RW_USERNAME}    ${RW_PASSWORD}
    ${rsp}=    RW.RunWhen.Papi.Get All Recents In Workspace    ${RW_E2E_WS}    30m    30s
    ${rsp}=    RW.RunWhen.Papi.Validate Recent Results    ${rsp}
    Log    ${rsp}

Get All Recents Across All Workspaces And Validate
    RW.RunWhen.Papi.Authenticate    ${RW_USERNAME}    ${RW_PASSWORD}
    ${rsp}=    RW.RunWhen.Papi.Get All Recents In All Workspaces    30m    30s
    ${rsp}=    RW.RunWhen.Papi.Validate All Workspace Recent Results    ${rsp}
    ${all_failures}=    Evaluate    len($rsp)
    Log    ${rsp}

Get All Runsessions
    RW.RunWhen.Papi.Authenticate    ${RW_USERNAME}    ${RW_PASSWORD}
    ${rsp}=    RW.RunWhen.Papi.Get Runsessions    ${RW_E2E_WS}
    Log    ${rsp}

Get Single Runsession
    RW.RunWhen.Papi.Authenticate    ${RW_USERNAME}    ${RW_PASSWORD}
    ${rsp}=    RW.RunWhen.Papi.Get Runsessions    ${RW_E2E_WS}
    ${rsp}=    RW.RunWhen.Papi.Get Runsession    ${RW_E2E_WS}    ${rsp[0]["id"]}
    Log    ${rsp}

Get Runrequest Report
    RW.RunWhen.Papi.Authenticate    ${RW_USERNAME}    ${RW_PASSWORD}
    ${rsp}=    RW.RunWhen.Papi.Get Runsessions    ${RW_E2E_WS}
    ${slx}=    Set Variable    ${rsp[0]["runRequests"][0]["slxShortName"]}
    ${runrequest_id}=    Set Variable    ${rsp[0]["runRequests"][0]["id"]}
    ${rsp}=    RW.RunWhen.Papi.Get Runrequest Report    ${RW_E2E_WS}    ${slx}    ${runrequest_id}
    Log    ${rsp}

Get Runsession Url
    RW.RunWhen.Papi.Authenticate    ${RW_USERNAME}    ${RW_PASSWORD}
    ${rsp}=    RW.RunWhen.Papi.Get Runsessions    ${RW_E2E_WS}
    ${runsession_id}=    Set Variable    ${rsp[0]["id"]}
    ${rsp}=    RW.RunWhen.Papi.Get Runsession Report    ${RW_E2E_WS}    ${runsession_id}
    Log    ${rsp}
    ${rsp}=    RW.RunWhen.Papi.Get Runsession Url    ${RW_E2E_WS}    ${runsession_id}
    Log    ${rsp}

*** Keywords ***
Suite Initialization
    Set Suite Variable    ${RW_USERNAME}    %{RW_USERNAME}
    Set Suite Variable    ${RW_PASSWORD}    %{RW_PASSWORD}
    Set Suite Variable    ${RW_API_BASE_URL}    %{RW_API_BASE_URL}
    Set Suite Variable    ${RW_E2E_WS}    %{RW_E2E_WS}
    Set Suite Variable    ${RW_E2E_DEFAULT_SLX}    %{RW_E2E_DEFAULT_SLX}
    Set Suite Variable    ${RW_RUNSESSION_ID}    %{RW_RUNSESSION_ID}
    Set Suite Variable    ${RW_RUNREQUEST_ID}    %{RW_RUNREQUEST_ID}
    Set Suite Variable    ${RW_WORKSPACE}    %{RW_WORKSPACE}
