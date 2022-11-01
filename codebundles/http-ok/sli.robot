*** Settings ***
Metadata          Author    Jonathan Funk
Documentation     Check if an HTTP request fails or times out of a given latency window.
...               This codebundle performs a measurement of 2 common golden signals: errors & latency, returning a 1 when either
...               a HTTP error status code is returned, or the response time is outside of the configured latency window. A value of 0 for the SLI
...               is considered a success.
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
    ...    description=The maximum latency as a float allowed for requests to have.
    ...    pattern=\w*
    ...    default=1.2
    ...    example=1.2
    ${rsp}=    RW.HTTP.Get    ${URL}
    ${latency}=    Set Variable    ${rsp.latency}
    ${latency_within_target}=    Evaluate    1 if ${latency} <= ${TARGET_LATENCY} else 0
    ${status_code}=    Set Variable    ${rsp.status_code}
    ${ok}=    Set Variable    ${rsp.ok}
    ${ok_int}=    Evaluate    1 if ${ok} else 0
    # The following allows us to do short-circuit math with results, but is also consistent with 0 being 'good'
    ${score}=    Evaluate    int(not ${latency_within_target}*${ok_int})
    Log    response obj: ${rsp}
    Log    latency: ${latency}
    Log    latency: ${latency_within_target}
    Log    status_code: ${status_code}
    Log    is ok: ${ok}
    Log    is ok: ${ok_int}
    Log    score: ${score}
    RW.Core.Push Metric    ${score}
