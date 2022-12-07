
*** Settings ***
Metadata          Author    Jonathan Funk
Documentation     This codebundle sets up a monitor for a specific region and GCP Product, which is then periodically checked for
...               ongoing incidents based on the history available at https://status.cloud.google.com/incidents.json filtered based on severity level.
Force Tags        GCP    Status    Health    services    Up    Available    Platform    Google    Cloud    Incidents
Library           RW.Core
Library           RW.GCP.ServiceHealth

*** Tasks ***
Get Number of GCP Incidents Effecting My Workspace
    RW.Core.Import User Variable    WITHIN_TIME
    ...    type=string
    ...    pattern=((\d+?)d)?((\d+?)h)?((\d+?)m)?((\d+?)s)?
    ...    description=How far back in incident history to check, in the format "1d1h15m", with possible unit values being 'd' representing days, 'h' representing hours, 'm' representing minutes, and 's' representing seconds.
    ...    example=30m
    ...    default=15m
    RW.Core.Import User Variable    PRODUCTS
    ...    type=string
    ...    description=Which product(s) to monitor for incidents. Accepts CSV. For further examples refer to the product names at https://status.cloud.google.com/index.html
    ...    pattern=\w*
    ...    default=Google Kubernetes Engine
    ...    example=Google Kubernetes Engine,Google Cloud Console
    RW.Core.Import User Variable    REGIONS
    ...    type=string
    ...    description=Which region to monitor for incidents. Accepts CSV. For further region value examples refer to any of the region tabs, eg: https://status.cloud.google.com/regional/americas
    ...    pattern=\w*
    ...    default=us-central1
    ...    example=us-central1,us-west2
    RW.Core.Import User Variable    SEVERITY
    ...    type=string
    ...    enum=[low,medium,high]
    ...    description=What level of severity to consider for counting as incidents.
    ...    example=low
    ...    default=low
    ${history}=    RW.GCP.ServiceHealth.Get Status Json
    ${filtered}=    RW.GCP.ServiceHealth.Filter Status Results    ${history}    ${WITHIN_TIME}
    ${metric}=    Evaluate    len($filtered)
    Log    count: ${metric}
    RW.Core.Push Metric    ${metric}
