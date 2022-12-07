*** Settings ***
Documentation     Monitors the average timing of a github actions workflow file within a repo
...               and returns the average runtime in minutes.
Metadata          Name    github-actions-timings
Metadata          Type    SLI
Metadata          Author    Jonathan Funk
Force Tags        github    actions    timing    monitor
Library           RW.Core
Library           RW.GitHub.Actions
Library           RW.Utils
Suite Setup       Suite Initialization

*** Keywords ***
Suite Initialization
    ${OWNER}=    RW.Core.Import User Variable    OWNER
    ...    type=string
    ...    description=The owner or organization name for the repo.
    ...    pattern=\w*
    ...    example=my-org
    ${REPO}=    RW.Core.Import User Variable    REPO
    ...    type=string
    ...    description=The name of the github repository.
    ...    pattern=\w*
    ...    example=myproject
    ${WORKFLOW_FILE}=    RW.Core.Import User Variable    WORKFLOW_FILE
    ...    type=string
    ...    description=The filename of the github workflow.
    ...    pattern=\w*
    ...    example=my-cicd.yaml
    ${DURATION}=    RW.Core.Import User Variable    DURATION
    ...    type=string
    ...    pattern=((\d+?)d)?((\d+?)h)?((\d+?)m)?((\d+?)s)?
    ...    description=How much history to include in calculations. This range is in the format "1d7h10m", with possible unit values being 'd' representing days, 'h' representing hours, 'm' representing minutes, and 's' representing seconds.
    ...    example=30d
    ${github-read-token}=    RW.Core.Import Secret    github-read-token
    ...    type=string
    ...    description=The github token to use.
    ...    pattern=\w*
    ...    example=my-super-secret-token

*** Tasks ***
Get Average Run Time For Workflow
    ${times}=    RW.GitHub.Actions.Get Workflow Times
    ...    owner=${OWNER}
    ...    repo=${REPO}
    ...    workflow_filename=${WORKFLOW_FILE}
    ...    within_time=${DURATION}
    ...    token=${github-read-token}
    ${avg_seconds}=    RW.Utils.Aggregate    method=Average    column=${times}
    ${avg_minutes}=    Evaluate    ${avg_seconds}/60
    RW.Core.Push Metric    ${avg_minutes}
