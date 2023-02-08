*** Settings ***
Metadata          Author    Shea Stewart
Documentation     A curl SLI for querying and extracting data from a generic curl call. Supports jq. Should prodice a single metric.
Force Tags        HTTP    CURL    NOAUTH    DATA    GET   REQUEST
Suite Setup       Suite Initialization
Library           RW.Core
Library           RW.Utils

*** Keywords ***
Suite Initialization
    ${CURL_COMMAND}=    RW.Core.Import User Variable    CURL_COMMAND
    ...    type=string
    ...    description=Curl command to run; should return a single metric. Can use jq for json parsing.  
    ...    pattern=\w*
    ...    default=curl --silent -X GET https://postman-echo.com/get | jq length
    ...    example=curl --silent -X GET https://postman-echo.com/get | jq length
    ${curl}=    RW.Core.Import Service    curl
    ...    type=string
    ...    description=The selected RunWhen Service to use for accessing services within a network.
    ...    pattern=\w*
    ...    example=curl-service.shared
    ...    default=curl-service.shared

*** Tasks ***
Run Curl Command and Push Metric
    ${rsp}=    RW.Core.Shell
    ...    cmd=${CURL_COMMAND}
    ...    service=${curl}
    ${metric}=     Convert To Number    ${rsp.stdout}
    RW.Core.Push Metric    ${metric}