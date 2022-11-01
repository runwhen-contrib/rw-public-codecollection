*** Settings ***
Documentation     Check status of the Github platform or a specified set of GitHub services.
...               The metric supplied is a aggregated percentage indicating the availability of the components.
Metadata          Name    github-status-component-availability
Metadata          Type    SLI
Metadata          Author    Paul Dittaro
Force Tags        github    availability
Library           RW.Core
Library           RW.GitHub.Status

*** Tasks ***
Get Availability of GitHub or Individual GitHub Components
    Log    Importing config variables...
    RW.Core.Import User Variable    GITHUB_COMPONENTS
    ...    type=string
    ...    description=The CSV list of Github Components to use to determine availability.
    ...    example=Webhooks,Actions,Git Operations,API Requests,Webhooks,Issues,Pull Requests,Actions,Packages,Pages,Codespaces,Copilot
    ${PARSED_GITHUB_COMPONENTS}=    Evaluate    set($GITHUB_COMPONENTS.split(',')) if $GITHUB_COMPONENTS is not "" else None
    ${metric}=    RW.GitHub.Status.Get Github Availability    ${PARSED_GITHUB_COMPONENTS}
    Log    metric: ${metric}
    RW.Core.Push Metric    ${metric}
