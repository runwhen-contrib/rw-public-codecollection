
*** Settings ***
Metadata          Author    Jonathan Funk
Documentation     This codebundle sets up a monitor for a specific region and GCP Product, which is then periodically checked for
...               ongoing incidents based on the history available at https://status.cloud.google.com/incidents.json filtered based on severity level.
Force Tags        GCP    Status    Health    services    Up    Available    Platform    Google    Cloud    Incidents
Library           RW.Core
Library           RW.GCP.ServiceHealth

*** Tasks ***
Get Number of GCP Incidents Effecting My Workspace
    Log    Importing config variables...
    RW.Core.Import User Variable    SECONDS_IN_PAST
    ...    type=string
    ...    description=The number of seconds of history to consider for SLI values. Depends on provider's sampling rate. Consider 600 as a starter.
    ...    pattern="^[0-9]*$"
    ...    example=600
    ...    default=600
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
    ${filtered}=    RW.GCP.ServiceHealth.Filter Status Results    ${history}    ${SECONDS_IN_PAST}
    ${metric}=    Evaluate    len($filtered)
    Log    count: ${metric}
    RW.Core.Push Metric    ${metric}
