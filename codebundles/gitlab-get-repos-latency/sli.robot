*** Settings ***
Documentation     Check GitLab latency by getting a list of repo names.
Metadata          Display Name    GitLab Get Repo Latency 
Metadata          Supports    GitLab
Metadata          Type    SLI
Metadata          Author    Vui Le
Force Tags        gitlab    latency
Library           RW.Core
Library           RW.GitLab
#TODO: Refactor for new platform use

*** Tasks ***
Check GitLab Latency With Get Repos
    Import User Variable    GITLAB_TOKEN
    Import User Variable    GITLAB_URL
    Import User Variable    SERVICE_DESCR
    RW.GitLab.Create Session    ${GITLAB_URL}    ${GITLAB_TOKEN}
    ${res} =    RW.GitLab.Get Projects
    Info Log    ${res.names}
    Push Metric    ${res.latency}    descr=${SERVICE_DESCR}
