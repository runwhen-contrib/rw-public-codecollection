*** Settings ***
Documentation     Check Pingdom health
Metadata          Name    pingdom-health
Metadata          Type    SLI
Metadata          Author    Vui Le
Force Tags        Pingdom    health
Library           RW.Core
Library           RW.Pingdom
#TODO: Refactor for new platform use

*** Tasks ***
Check Pingdom Health
    ${res} =    RW.Pingdom.Get Health Status
    Info Log    ${res}
    Console Log    ${res.status_code}
    Console Log    ${res.content}
#    Console Log If True    ${res.status_code} != 200    status_code: ${res.status_code}
#    Console Log If True    ${res.status_code} != 200    reason: ${res.reason}
#
#    Push Metric    ${res.ok}    descr=${SERVICE_DESCR}
#    ...    status_code=${res.status_code}
#    ...    cluster_name=${res.cluster_name}
#    ...    sealed=${res.sealed}
#    ...    standby=${res.standby}
