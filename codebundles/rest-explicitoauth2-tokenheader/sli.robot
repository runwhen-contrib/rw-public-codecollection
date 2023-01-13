*** Settings ***
Metadata          Author    Jonathan Funk
Documentation     A REST SLI for querying and extracting data from a REST endpoint that needs an explicit oauth2 flow.
...               Where an access token must be acquired with a bearer token.
Force Tags        HTTP    REST    OUATH2    DATA    GET    POST    VERBS    REQUEST
Suite Setup       Suite Initialization
Library           RW.Core
Library           RW.Rest
Library           RW.Utils

*** Keywords ***
Suite Initialization
    ${BEARER_TOKEN}=    RW.Core.Import Secret    BEARER_TOKEN
    ...    type=string
    ...    description=The bearer token string used to authenticate during ouath2.
    ...    pattern=\w*
    ...    example=mybearertoken
    ${AUTH_URL}=    RW.Core.Import User Variable    AUTH_URL
    ...    type=string
    ...    description=The authentication URL to request a token from.
    ...    pattern=\w*
    ...    example=https://my-token-api/api/v1/token
    ...    default=https://postman-echo.com/
    ${AUTH_TOKEN_JSON_PATH}=    RW.Core.Import User Variable    AUTH_TOKEN_JSON_PATH
    ...    type=string
    ...    description=The json path used to extract the token value from the authentication response.
    ...    pattern=\w*
    ...    example=If your json rsp was: {"access":"mytokenvalue"}, using 'access' as the json path would extract 'mytokenvalue'
    ...    default=access
    ${HEADERS}=    RW.Core.Import Secret    HEADERS
    ...    type=string
    ...    description=Optional. A json string of headers to include in the request against the REST endpoint. This can include your token.
    ...    pattern=\w*
    ...    default={}
    ...    example={"Content-Type":"application/json"}
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
    Set Suite Variable    ${BEARER_TOKEN}    ${BEARER_TOKEN}
    Set Suite Variable    ${AUTH_URL}    ${AUTH_URL}
    Set Suite Variable    ${AUTH_TOKEN_JSON_PATH}    ${AUTH_TOKEN_JSON_PATH}
    Set Suite Variable    ${HEADERS}    ${HEADERS}
    Set Suite Variable    ${URL}    ${URL}
    Set Suite Variable    ${JSON_DATA}    ${JSON_DATA}
    Set Suite Variable    ${PARAMS}    ${PARAMS}
    Set Suite Variable    ${JSON_PATH}    ${JSON_PATH}

*** Tasks ***
Request Data From Rest Endpoint
    ${bearer_token}=    RW.Rest.Create Bearer Token Header    ${BEARER_TOKEN}
    ${token}=    RW.Rest.Request As Secret
    ...    created_secret_key=access_key
    ...    rsp_extract_json_path=${AUTH_TOKEN_JSON_PATH} 
    ...    method=POST
    ...    url=${AUTH_URL}
    ...    headers=${bearer_token}
    ${access_token}=    RW.Rest.Create Bearer Token Header    ${token}
    ${headers}=    RW.Utils.Merge Json Secrets    ${HEADERS}    ${access_token}
    ${rsp}=    RW.Rest.Request
    ...    url=${URL}
    ...    json=${JSON_DATA}
    ...    params=${PARAMS}
    ...    headers=${headers}
    ${metric}=    RW.Rest.Handle Response
    ...    rsp=${rsp}
    ...    json_path=${JSON_PATH}
    RW.Core.Push Metric    ${metric}
