*** Settings ***
Metadata          Author    Jonathan Funk
Documentation     This codebundle performs a measurement of golden signal: latency. The returned metric is the number of seconds
...               the request took as a float value.
Force Tags        Url    HTTP    Latency    Metric
Library           RW.Core
Library           RW.HTTP

*** Tasks ***
Check HTTP Latency to Well Known URL
    ${URL}=    RW.Core.Import User Variable    URL
    ...    type=string
    ...    description=What URL to perform requests against.
    ...    pattern=\w*
    ...    default=https://www.runwhen.com
    ...    example=https://www.runwhen.com
    ${rsp}=    RW.HTTP.Get    ${URL}    expected_status=200
    RW.Core.Debug Log    Latency in seconds: ${rsp.latency}
    RW.Core.Push Metric    ${rsp.latency}
