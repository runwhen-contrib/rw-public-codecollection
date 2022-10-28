*** Settings ***
Documentation     Check availability of the GitLab server
Metadata          Name    gitlab-availability
Metadata          Type    SLI
Metadata          Author    Vui Le
Force Tags        gitlab    availability
Library           RW.Core
Library           RW.HTTP
#TODO: Refactor for new platform use

*** Tasks ***
Check GitLab Server Status
    Import User Variable    SERVICE_DESCR
    Import User Variable    GITLAB_URL
    Import User Variable    GITLAB_ACCESS_TOKEN
    ${session} =    Create Authenticated Session    url=${GITLAB_URL}    headers={"PRIVATE-TOKEN": "${GITLAB_ACCESS_TOKEN}"}    verbose=true
    ${res} =    GET    ${GITLAB_URL}    session=${session}    verbose=true
    Debug Log    ${res}
    Push Metric    ${res.status_code}    descr=${SERVICE_DESCR}
#    ...    status_code=${res.status_code}
#    ...    ok=${res.ok}
#    ...    ok_status=${res.ok_status}
