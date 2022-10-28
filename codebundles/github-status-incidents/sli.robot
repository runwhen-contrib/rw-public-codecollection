*** Settings ***
Documentation     Check for unresolved incidents related to GitHub services, and provides a count of ongoing incidents as a metric.
Metadata          Name    github-status-incidents
Metadata          Type    SLI
Metadata          Author    Paul Dittaro
Force Tags        github    availability
Library           RW.Core
Library           RW.GitHub.Status

*** Tasks ***
Get Number of Incidents Affecting GitHub
    Log    Importing config variables...
    RW.Core.Import User Variable    INCIDENT_IMPACT
    ...    type=string
    ...    enum=[None,Minor,Major,Critical]
    ...    description=Impact level to filter unresolved incidents to. Filtering to a lower level will include all incidents of a higher impact level.
    ...    example=Minor
    ...    default=None
    ${incidents}=    RW.GitHub.Status.Get Unresolved Incidents    ${INCIDENT_IMPACT}
    ${metric}=    Evaluate    len($incidents)
    Log    count: ${metric}
    RW.Core.Push Metric    ${metric}
