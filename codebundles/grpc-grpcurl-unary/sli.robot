*** Settings ***
Metadata          Author    Jonathan Funk
Metadata          Display Name    gRPC cURL Unary 
Metadata          Supports    gRPC,cURL
Documentation     A gRPC curl SLI for querying and extracting data from a generic grpcurl call.
Force Tags        GRPC    CURL
Suite Setup       Suite Initialization
Library           String
Library           RW.Core
Library           RW.Utils
Library           RW.gRPC.gRPCurl

*** Keywords ***
Suite Initialization
    ${OPTIONAL_HEADERS}=    RW.Core.Import Secret    OPTIONAL_HEADERS
    ...    type=string
    ...    description=Optional. A json string of headers to include in the request against the REST endpoint. This can include your token.
    ...    pattern=\w*
    ...    default={}
    ...    example={"Content-Type":"application/json"}
    ${GRPCURL_COMMAND}=    RW.Core.Import User Variable    GRPCURL_COMMAND
    ...    type=string
    ...    description=gRPCurl command to run; should return a single metric. You can also use jq for json parsing.
    ...    pattern=\w*
    ...    default=grpcurl -plaintext -d '{"greeting": "1"}' grpc.postman-echo.com:443 HelloService/SayHello | jq '(.reply | split(" "))[1]'
    ...    example=grpcurl -plaintext -d '{"greeting": "1"}' grpc.postman-echo.com:443 HelloService/SayHello | jq '(.reply | split(" "))[1]'
    ${GRPCURL_SERVICE}=    RW.Core.Import Service    grpcurl
    ...    type=string
    ...    description=The selected RunWhen Service to use for accessing services within a network.
    ...    pattern=\w*
    ...    example=grpcurl-service.shared
    ...    default=grpcurl-service.shared
    Set Suite Variable    ${GRPCURL_COMMAND}    ${GRPCURL_COMMAND}
    Set Suite Variable    ${GRPCURL_SERVICE}    ${GRPCURL_SERVICE}
    Set Suite Variable    ${OPTIONAL_HEADERS}    ${OPTIONAL_HEADERS}
    # TODO: design flow for proto files
    # TODO support more than unary method

*** Tasks ***
Run gRPCurl Command and Push Metric
    ${rsp}=    RW.gRPC.gRPCurl.Grpcurl Unary
    ...    cmd=${GRPCURL_COMMAND}
    ...    target_service=${GRPCURL_SERVICE}
    ...    optional_headers=${OPTIONAL_HEADERS}
    ${rsp}=    Remove String        ${rsp}   "    \n
    ${metric}=     Convert To Number    ${rsp}
    RW.Core.Push Metric    ${metric}