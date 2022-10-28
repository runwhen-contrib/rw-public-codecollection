*** Settings ***
Library           RW.Core
Library           RW.HTTP
Library           RW.Remote
#TODO: update remoter use and keyword

*** Tasks ***
Checking HTTP URL Is Available And Timely
    Log    Importing config variables...
    RW.Core.Import User Variable    URL
    RW.Core.Import User Variable    TARGET_LATENCY
    Log    Performing GET request...
    ${curl_cmd}=    Set Variable    "curl -w :\%\{response_code\}:\%\{time_total\} ${URL}"
    ${rsp}=    Remote Run    ${curl_cmd}
    ${stdout}=    Set Variable    ${rsp["stdout"]}
    ${stdout_list}=    Evaluate    '${stdout}'.split(':')
    ${body}=    Set Variable    ${stdout_list[0]}
    ${status_code}=    Set Variable    ${stdout_list[1]}
    ${ok_int}=    Evaluate    1 if ${status_code} >= 200 and ${status_code} < 300 else 0
    ${latency}=    Set Variable    ${rsp.stdout_list[2]}
    ${latency_within_target}=    Evaluate    1 if ${latency} <= ${TARGET_LATENCY} else 0
    ${success}=    Evaluate    ${latency_within_target}*${ok_int}
    Log    response obj: ${rsp}
    Log    latency: ${latency}
    Log    latency: ${latency_within_target}
    Log    status_code: ${status_code}
    Log    is ok: ${ok_int}
    Log    score: ${success}
    RW.Core.Push Metric    ${success}
