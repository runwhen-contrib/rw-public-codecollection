*** Settings ***
Documentation     Check Grafana server health
Metadata          Name    grafana-health
Metadata          Type    SLI
Metadata          Author    Vui Le
Force Tags        Grafana    health
Library           RW.Core
Library           RW.Grafana
#TODO: Refactor for new platform use

*** Tasks ***
Check Grafana Server Health
    ${res} =    RW.Grafana.Get Health Status
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
