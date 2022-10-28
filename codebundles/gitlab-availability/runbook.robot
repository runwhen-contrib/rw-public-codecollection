*** Settings ***
Documentation     Troubleshooting GitLab server availability
Metadata          Name    gitlab-availability
Metadata          Type    Runbook
Metadata          Author    Vui Le
Force Tags        gitlab    availability    troubleshooting
Suite Setup       Runbook Setup
Suite Teardown    Runbook Teardown
Library           RW.Core
Library           RW.HTTP
Library           RW.Report
Library           RW.Slack
#TODO: Refactor for new platform use

*** Tasks ***
Check GitLab Server Status
    ${session} =    Create Authenticated Session    url=${GITLAB_URL}    headers={"PRIVATE-TOKEN": "${GITLAB_ACCESS_TOKEN}"}    verbose=true
    Debug Log    ${session}
    ${res} =    GET    url=${GITLAB_URL}    session=${session}
    Debug Log    ${res}
    Add To Report    URL: ${GITLAB_URL}
    Add To Report    Error code: ${res.status_code}
    Add To Report    Error message: ${res.reason}
    Close Session    ${session}

*** Keywords ***
Runbook Setup
    Import User Variable    SERVICE_DESCR
    Import User Variable    GITLAB_URL
    Import User Variable    GITLAB_ACCESS_TOKEN
    Import User Variable    SLACK_CHANNEL
    Import User Variable    SLACK_BOT_TOKEN

Runbook Teardown
    ${report} =    Get Report
    Debug Log    ${report}    console=true
    RW.Slack.Post Message
    ...    token=${SLACK_BOT_TOKEN}
    ...    channel=${SLACK_CHANNEL}
    ...    flag=red
    ...    title=${SERVICE_DESCR} Troubleshooting Report
    ...    msg=${report}
