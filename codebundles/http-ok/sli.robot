*** Settings ***
Metadata          Author    Jonathan Funk
Metadata          Display Name    HTTP OK
Metadata          Supports    HTTP
Documentation     Check if an HTTP request against a URL fails or times out of a given latency window.
...               A return of 1 is considered a success, while a 0 is failure.
Force Tags        Url    Errors    HTTP    Status    Latency    Metric
Library           RW.Core
Library           RW.HTTP

*** Tasks ***
Checking HTTP URL Is Available And Timely
    ${URL}=    RW.Core.Import User Variable    URL
    ...    type=string
    ...    description=What URL to perform requests against.
    ...    pattern=\w*
    ...    default=https://www.runwhen.com
    ...    example=https://www.runwhen.com
    ${TARGET_LATENCY}=    RW.Core.Import User Variable    TARGET_LATENCY
    ...    type=string
    ...    description=The maximum latency in seconds as a float value allowed for requests to have.
    ...    pattern=\w*
    ...    default=1.2
    ...    example=1.2
    ${rsp}=    RW.HTTP.Get    ${URL}
    ${latency}=    Set Variable    ${rsp.latency}
    ${latency_within_target}=    Evaluate    1 if ${latency} <= ${TARGET_LATENCY} else 0
    ${status_code}=    Set Variable    ${rsp.status_code}
    ${ok}=    Set Variable    ${rsp.ok}
    ${ok_int}=    Evaluate    1 if ${ok} else 0
    ${score}=    Evaluate    int(${latency_within_target}*${ok_int})
    RW.Core.Push Metric    ${score}
