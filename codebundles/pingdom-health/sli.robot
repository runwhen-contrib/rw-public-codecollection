*** Settings ***
Documentation     Check health of Pingdom platform.
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
