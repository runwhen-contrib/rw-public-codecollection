*** Settings ***
Documentation     Check status of the GitHub platform (https://www.githubstatus.com/) for a specified set of GitHub service components.
...               The metric supplied is a aggregated percentage indicating the availability of the components.
Metadata          Name    github-status-component-availability
Metadata          Type    SLI
Metadata          Author    Paul Dittaro
Force Tags        github    availability statuspage status
Library           RW.Core
Library           RW.GitHub.Status

*** Tasks ***
Get Availability of GitHub or Individual GitHub Components
    Log    Importing config variables...
    RW.Core.Import User Variable    GITHUB_COMPONENTS
    ...    type=string
    ...    description=The CSV list of GitHub Components to use to determine availability. Visit https://www.githubstatus.com/ for complete list.
    ...    example=Webhooks,Actions,Git Operations,API Requests,Issues,Pull Requests,Packages,Pages,Codespaces,Copilot
    ${PARSED_GITHUB_COMPONENTS}=    Evaluate    set($GITHUB_COMPONENTS.split(',')) if $GITHUB_COMPONENTS is not "" else None
    ${metric}=    RW.GitHub.Status.Get Github Availability    ${PARSED_GITHUB_COMPONENTS}
    Log    metric: ${metric}
    RW.Core.Push Metric    ${metric}
