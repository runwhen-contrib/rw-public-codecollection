*** Settings ***
Documentation     Runbook to create a new issue in GitHub Issues.
Metadata          Name    github-get-repos-latency
Metadata          Type    Runbook
Metadata          Author    Vui Le
Force Tags        github    latency    troubleshooting
Suite Setup       Runbook Setup
Library           RW.Core
Library           RW.GitHub
#TODO: Refactor for new platform use

*** Tasks ***
Check Latency When Creating a New GitHub Issue
    [Documentation]    Create a new issue in GitHub issues. Report the latency.
    ${body} =    Catenate    SEPARATOR=\n
    ...    **Testing** *1 2 3*
    ...    1. item 1
    ...    1. item 2
    ...    ```
    ...    a : int = 1
    ...    b : int = 2
    ...    c : int = a + b
    ...    print(f"c is {c}")
    ...    ```
    ${res} =    RW.GitHub.Create Issue
    ...    token=${GITHUB_TOKEN}
    ...    repo_name=${GITHUB_REPO_NAME}
    ...    title=[Troubleshooting] Runbook: github-get-repos-latency
    ...    assignee=${USER}
    ...    labels=troubleshooting
    ...    body=${body}
    Info Log    GitHub Create Issue result: ${res}
    Info Log    GitHub Create Issue latency: ${res.latency}

*** Keywords ***
Runbook Setup
    Import User Variable    GITHUB_REPO_NAME
    Import User Variable    GITHUB_TOKEN
    Import User Variable    GITHUB_USER
