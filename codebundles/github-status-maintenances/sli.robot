*** Settings ***
Documentation     Retrieve number of upcoming Github platform maintenances over a given window.
Metadata          Display Name    GitHub Status Maintenance
Metadata          Supports    GitHub,Status 
Metadata          Type    SLI
Metadata          Author    Paul Dittaro
Force Tags        github    availability
Library           RW.Core
Library           RW.GitHub.Status

*** Tasks ***
Get Scheduled and Active GitHub Maintenance Windows
    Log    Importing config variables...
    RW.Core.Import User Variable    DURATION
    ...    type=string
    ...    pattern=((\d+?)d)?((\d+?)h)?((\d+?)m)?((\d+?)s)?
    ...    description=How far ahead to retrieve scheduled maintenances, in the format "1d7h10m", with possible unit values being 'd' representing days, 'h' representing hours, 'm' representing minutes, and 's' representing seconds.
    ...    example=1d7h10m
    ${PARSED_DURATION}=    Evaluate    $DURATION if $DURATION is not "" else None
    ${maintenances}=    RW.GitHub.Status.Get Scheduled Maintenances    ${PARSED_DURATION}
    ${metric}=    Evaluate    len($maintenances)
    Log    count: ${metric}
    RW.Core.Push Metric    ${metric}
