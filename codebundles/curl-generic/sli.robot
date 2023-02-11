*** Settings ***
Metadata          Author    Shea Stewart
Documentation     A curl SLI for querying and extracting data from a generic curl call. Supports jq. Should prodice a single metric.
Force Tags        HTTP    CURL    NOAUTH    DATA    GET   REQUEST
Suite Setup       Suite Initialization
Library           RW.Core
Library           RW.Utils
Library           RW.Curl

*** Keywords ***
Suite Initialization
    ${OPTIONAL_HEADERS}=    RW.Core.Import Secret    OPTIONAL_HEADERS
    ...    type=string
    ...    description=Optional. A json string of headers to include in the request against the REST endpoint. This can include your token.
    ...    pattern=\w*
    ...    default="{}"
    ...    example=`{"Content-Type":"application/json"}`
    ${CURL_COMMAND}=    RW.Core.Import User Variable    CURL_COMMAND
    ...    type=string
    ...    description=Curl command to run; should return a single metric. Can use jq for json parsing.  
    ...    pattern=\w*
    ...    default=curl --silent -X GET https://postman-echo.com/get | jq length
    ...    example=curl --silent -X GET https://postman-echo.com/get | jq length
    ${CURL_SERVICE}=    RW.Core.Import Service    curl
    ...    type=string
    ...    description=The selected RunWhen Service to use for accessing services within a network.
    ...    pattern=\w*
    ...    example=curl-service.shared
    ...    default=curl-service.shared
    Set Suite Variable    ${CURL_SERVICE}    ${CURL_SERVICE}
    Set Suite Variable    ${OPTIONAL_HEADERS}    ${OPTIONAL_HEADERS}

*** Tasks ***
Run Curl Command and Push Metric
    ${rsp}=    RW.Curl.Run Curl
    ...    cmd=${CURL_COMMAND}
    ...    target_service=${CURL_SERVICE}
    ...    optional_headers=${OPTIONAL_HEADERS}
    ${metric}=     Convert To Number    ${rsp}
    RW.Core.Push Metric    ${metric}