*** Settings ***
Documentation     Create an issue in Jira.
Suite Setup       Runbook Setup
Library           RW.Core
Library           RW.Jira
#TODO: Refactor for new platform use

*** Keywords ***
Runbook Setup
    Import User Variable    JIRA_URL
    Import User Variable    JIRA_USER
    Import User Variable    JIRA_USER_TOKEN

*** Tasks ***
Create a new Jira Issue
    [Documentation]    Create a new issue in Jira
    Connect to Jira    server=${JIRA_URL}    user=${JIRA_USER}    token=${JIRA_USER_TOKEN}
    ${res} =    RW.Jira.Create Issue
    ...    project=TJ    summary=This is a test    description=Add more details here.
    Info Log    Created issue: ${res.key}
    # Get all fields for issue.
    ${res} =    RW.Jira.Get Issue    issue_id=${res.key}    verbose=${true}
    # Get specific fields for issue.
    ${res} =    RW.Jira.Get Issue
    ...    issue_id=${res.key}    fields=assignee,summary,status,priority
    ${msg} =    Catenate    Issue details:
    ...    assignee=${res.fields.assignee},
    ...    summary=${res.fields.summary},
    ...    status=${res.fields.status},
    ...    priority=${res.fields.priority}
    Info Log    ${msg}
    Assign Issue    ${res.key}    Vui Le
