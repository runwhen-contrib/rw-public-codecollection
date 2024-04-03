*** Settings ***
Metadata          Author    Jonathan Funk
Metadata          Display Name    GCP GCloud Generic Metric
Metadata          Supports    GCP,gcloud
Documentation     Run arbitrary gcloud commands and parse their output for arbitrary values such as json to be submitted as a metric.
Force Tags        GCLOUD    CLI    JSON    DATA
Suite Setup       Suite Initialization
Library           RW.Core
Library           RW.Utils
Library           RW.GCP.GCloudCLI

*** Keywords ***
Suite Initialization
    ${GCLOUD_COMMAND}=    RW.Core.Import User Variable    GCLOUD_COMMAND
    ...    type=string
    ...    description=gcloud command to run; should return a single metric. Can use jq for json parsing.  
    ...    pattern=\w*
    ...    default=gcloud logging read "severity>=WARNING" --freshness=15m --limit=20 --format=json | jq length
    ...    example=gcloud logging read "severity>=WARNING" --freshness=15m --limit=20 --format=json | jq length
    ${GCLOUD_SERVICE}=    RW.Core.Import Service    gcloud
    ...    type=string
    ...    description=The selected RunWhen Service to use for accessing services within a network.
    ...    pattern=\w*
    ...    example=gcloud-service.shared
    ...    default=gcloud-service.shared
    ${gcp_credentials_json}=    RW.Core.Import Secret    gcp_credentials_json
    ...    type=string
    ...    description=GCP service account json used to authenticate with GCP APIs.
    ...    pattern=\w*
    ...    example={"type": "service_account","project_id":"myproject-ID", ... super secret stuff ...}
    ${PROJECT_ID}=    RW.Core.Import User Variable    PROJECT_ID
    ...    type=string
    ...    description=The GCP Project ID to scope the API to.
    ...    pattern=\w*
    ...    example=myproject-ID
    Set Suite Variable    ${GCLOUD_COMMAND}    ${GCLOUD_COMMAND}
    Set Suite Variable    ${GCLOUD_SERVICE}    ${GCLOUD_SERVICE}
    Set Suite Variable    ${gcp_credentials_json}    ${gcp_credentials_json}
    Set Suite Variable    ${PROJECT_ID}    ${PROJECT_ID}

*** Tasks ***
Run Gcloud CLI Command and Push metric
    ${rsp}=    RW.GCP.GCloudCLI.Shell
    ...    cmd=${GCLOUD_COMMAND}
    ...    target_service=${GCLOUD_SERVICE}
    ...    gcp_credentials_json=${gcp_credentials_json}
    ...    project_id=${PROJECT_ID}
    ${metric}=     Convert To Number    ${rsp}
    RW.Core.Push Metric    ${metric}