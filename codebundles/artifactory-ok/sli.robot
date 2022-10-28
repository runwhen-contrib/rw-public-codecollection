*** Settings ***
Metadata          Author    Jonathan Funk
Documentation     A codebundle which periodically performs a GET request against a Artifactory URL for health information.
...               The response is parsed to determine if the service is healthy, resulting in a metric of 1 if it is, or 0 if not.
Force Tags        Arty    Artifactory    health    HTTP
Library           RW.Core
Library           RW.Artifactory

*** Tasks ***
Check If Artifactory Endpoint Is Healthy
    ${ARTIFACTORY_HEALTH_URL}=    RW.Core.Import User Variable    ARTIFACTORY_HEALTH_URL
    ...    type=string
    ...    description=What URL to retrieve health data from.
    ...    pattern=\w*
    ...    default=https://my-artifactory.com/router/api/v1/system/health
    ...    example=https://my-artifactory.com/router/api/v1/system/health
    ${rsp}=    RW.Artifactory.Get Health    url=${ARTIFACTORY_HEALTH_URL}
    ${status}=    RW.Artifactory.Validate Health    health_data=${rsp}
    ${score}=    Evaluate    1 if ${status} is True else 0
    RW.Core.Push Metric    ${score}
