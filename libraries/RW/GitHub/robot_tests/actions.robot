*** Settings ***
Library           RW.GitHub.Actions
Library           RW.Utils
Suite Setup       Suite Initialization

*** Keywords ***
Suite Initialization
    ${GITHUB_SLI_TOKEN}=    Evaluate    RW.platform.Secret("github-read-token", """%{GITHUB_SLI_TOKEN}""")
    Set Suite Variable    ${GITHUB_SLI_TOKEN}    ${GITHUB_SLI_TOKEN}

*** Variables ***
${OWNER}          runwhen-contrib
${REPO}           rw-public-codecollection
${WORKFLOW_FILENAME}    generate-index.yml

*** Tasks ***
Get A Workflow's Runs
    ${rsp}=    RW.GitHub.Actions.Get Workflow Runs
    ...    owner=${OWNER}
    ...    repo=${REPO}
    ...    workflow_filename=${WORKFLOW_FILENAME}
    ...    token=${GITHUB_SLI_TOKEN}

Get A Workflow's Usage Stats
    ${rsp}=    RW.GitHub.Actions.Get Workflow Usage
    ...    owner=${OWNER}
    ...    repo=${REPO}
    ...    workflow_filename=${WORKFLOW_FILENAME}
    ...    token=${GITHUB_SLI_TOKEN}

Get Usage Of Last Run
    ${rsp}=    RW.GitHub.Actions.Get Workflow Runs
    ...    owner=${OWNER}
    ...    repo=${REPO}
    ...    workflow_filename=${WORKFLOW_FILENAME}
    ...    token=${GITHUB_SLI_TOKEN}
    ${last_run_id}=    Set Variable    ${rsp["workflow_runs"][0]["id"]}
    ${usage}=    RW.GitHub.Actions.Get Workflow Run Usage
    ...    owner=${OWNER}
    ...    repo=${REPO}
    ...    run_id=${last_run_id}
    ...    token=${GITHUB_SLI_TOKEN}

Get Workflow Times For Last 30 Days
    ${times}=    RW.GitHub.Actions.Get Workflow Times
    ...    owner=${OWNER}
    ...    repo=${REPO}
    ...    workflow_filename=${WORKFLOW_FILENAME}
    ...    token=${GITHUB_SLI_TOKEN}
    ${avg}=    RW.Utils.Aggregate    method=Average    column=${times}

Get Workflow Times For Last 15 Days
    ${times}=    RW.GitHub.Actions.Get Workflow Times
    ...    owner=${OWNER}
    ...    repo=${REPO}
    ...    workflow_filename=${WORKFLOW_FILENAME}
    ...    within_time=15d
    ...    token=${GITHUB_SLI_TOKEN}
    ${avg}=    RW.Utils.Aggregate    method=Average    column=${times}
