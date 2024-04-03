*** Settings ***
Metadata          Author    Jonathan Funk
Metadata          Display Name    Web Triage
Metadata          Supports    HTTP 
Documentation     Troubleshoot and triage a URL to inspect it for common issues such as an expired certification, missing DNS records, etc.
Force Tags        Url    Errors    HTTP    Status    Latency    Triage    DNS    SSL    Certificate
Library           RW.Core
Library           RW.WebInspector
Suite Setup       Suite Initialization

*** Keywords ***
Suite Initialization
    RW.Core.Import User Variable    URL
    ...    type=string
    ...    description=What URL to perform checks against.
    ...    pattern=\w*
    ...    default=https://www.runwhen.com
    ...    example=https://www.runwhen.com
    RW.Core.Import User Variable    REQUEST_COUNT
    ...    type=string
    ...    description=How many requests to perform for measuring response times.
    ...    pattern=\w*
    ...    default=10
    ...    example=10
    Set Suite Variable    ${URL}    ${URL}
    Set Suite Variable    ${REQUEST_COUNT}    ${REQUEST_COUNT}

*** Tasks ***
Validate Platform Egress
    ${success}=    RW.WebInspector.Verify Egress
    RW.Core.Add To Report    Web Inspection Validate Platform Egress Success: ${success}

Perform Inspection On URL
    ${inspection}=    RW.WebInspector.Inspect Url    ${URL}    ${REQUEST_COUNT}
    ${success_ratio_percentage}    Evaluate    int(${inspection["latency_info"]["success_ratio"]}*100)
    ${cert_valid_from}=    RW.WebInspector.Get Cert Valid From    ${inspection}
    ${cert_valid_until}=    RW.WebInspector.Get Cert Valid Until    ${inspection}
    ${formated_latency}=    Set Variable    "${inspection["latency_info"]["average_latency"]} second(s)/per request average over ${REQUEST_COUNT} requests"
    ${formated_success_ratio}=    Set Variable    "${success_ratio_percentage}% of ${REQUEST_COUNT} requests"
    ${formatted_dns_info}=    Set Variable    ${inspection["dns_info"]}
    RW.Core.Add To Report    Web Inspection Report For URL: ${URL}
    RW.Core.Add To Report    Average Latency: ${formated_latency}
    RW.Core.Add To Report    Certificate valid from: ${cert_valid_from} until ${cert_valid_until}
    RW.Core.Add To Report    Success Ratio: ${formated_success_ratio}
    RW.Core.Add To Report    DNS Information: ${inspection["dns_info"]}
    RW.Core.Add To Report    ---
    RW.Core.Add To Report    Full Inspection:
    RW.Core.Add Json To Report    ${inspection}
