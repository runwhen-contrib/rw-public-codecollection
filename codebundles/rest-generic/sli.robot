*** Settings ***
Metadata          Author    Jonathan Funk
Documentation     A general purpose REST SLI for querying and extracting data from a REST endpoint that uses a implicit oauth2 flow.
Force Tags        HTTP    REST    OAUTH2    DATA    GET    POST    VERBS    REQUEST
Suite Setup       Suite Initialization
Library           RW.Core
Library           RW.Rest

*** Keywords ***
Suite Initialization
    ${HEADERS}=    RW.Core.Import Secret    HEADERS
    ...    type=string
    ...    description=Optional. A json string of headers to include in the request against the REST endpoint. This can include your token.
    ...    pattern=\w*
    ...    default={}
    ...    example={"Content-Type":"application/json", "my-header":"my-value", "Authorization":"Bearer mytoken"}
    ${URL}=    RW.Core.Import User Variable    URL
    ...    type=string
    ...    description=The URL to perform the request against.
    ...    pattern=\w*
    ...    example=https://postman-echo.com/get
    ...    default=https://postman-echo.com/get
    ${PARAMS}=    RW.Core.Import User Variable    PARAMS
    ...    type=string
    ...    description=Optional. HTTP URL query parameters to use during the request.
    ...    pattern=\w*
    ...    example={"mygetparam":1}
    ...    default={"mygetparam":1}
    ${JSON_DATA}=    RW.Core.Import User Variable    JSON_DATA
    ...    type=string
    ...    description=Optional. Json data to include in the body of the request.
    ...    pattern=\w*
    ...    example={"myjsondata":"data"}
    ...    default={"myjsondata":"data"}
    ${JSON_PATH}=    RW.Core.Import User Variable    JSON_PATH
    ...    type=string
    ...    description=A json path string that is used to extract data from the response.
    ...    pattern=\w*
    ...    example=data.myfield.nestedfield
    ...    default=args.mygetparam
    Set Suite Variable    ${HEADERS}    ${HEADERS}
    Set Suite Variable    ${URL}    ${URL}
    Set Suite Variable    ${JSON_DATA}    ${JSON_DATA}
    Set Suite Variable    ${PARAMS}    ${PARAMS}
    Set Suite Variable    ${JSON_PATH}    ${JSON_PATH}

*** Tasks ***
Request Data From Rest Endpoint
    ${rsp}=    RW.Rest.Request
    ...    url=${URL}
    ...    json=${JSON_DATA}
    ...    params=${PARAMS}
    ...    headers=${HEADERS}
    ${metric}=    RW.Rest.Handle Response
    ...    rsp=${rsp}
    ...    json_path=${JSON_PATH}
    RW.Core.Push Metric    ${metric}

