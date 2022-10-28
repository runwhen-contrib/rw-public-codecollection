*** Settings ***
Library           RW.GitHub.Status

*** Variables ***
${GITHUB_COMPONENTS}    {"Webhooks", "Actions"}
${INCIDENT_IMPACT}    Minor
${DURATION}       2d4h

*** Tasks ***
Get Availability of GitHub:
    ${availability} =    Get Github Availability
    Log To Console    ${availability}

Get Availability of Select GitHub Components:
    ${availability} =    Get Github Availability    ${GITHUB_COMPONENTS}
    Log To Console    ${availability}

Get Number of Unresolved GitHub Incidents:
    ${incidents}=    Get Unresolved Incidents
    ${metric}=    Evaluate    len($incidents)
    Log To Console    ${metric}

Get Number of Unresolved GitHub Incidents of at least Minor impact:
    ${incidents}=    Get Unresolved Incidents    ${INCIDENT_IMPACT}
    ${metric}=    Evaluate    len($incidents)
    Log To Console    ${metric}

Get Number of Active Scheduled Maintenances:
    ${maintenances}=    Get Scheduled Maintenances
    ${metric}=    Evaluate    len($maintenances)
    Log To Console    ${metric}

Get Number of Active Scheduled Maintenances Over The Next Week:
    ${maintenances}=    Get Scheduled Maintenances    ${DURATION}
    ${metric}=    Evaluate    len($maintenances)
    Log To Console    ${metric}
