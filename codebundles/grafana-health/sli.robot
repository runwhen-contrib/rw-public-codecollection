*** Settings ***
Documentation     Check Grafana server health.
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
