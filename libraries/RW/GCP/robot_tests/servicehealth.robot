*** Settings ***
Library           RW.GCP.ServiceHealth

*** Variables ***
${SECONDS_IN_PAST}    1m
${PRODUCT_LIST}    Google Cloud Console, Google Cloud SQL, Google Kubernetes Engine
${REGION}         us-central1, us-west2

*** Tasks ***
Get Number Of GCP Incidents
    ${history}=    RW.GCP.ServiceHealth.Get Status Json
    ${filtered}=    RW.GCP.ServiceHealth.Filter Status Results    ${history}    ${SECONDS_IN_PAST}
    ${metric}=    Evaluate    len($filtered)

Get Number Of GCP Incidents For 2 Products
    ${history}=    RW.GCP.ServiceHealth.Get Status Json
    ${filtered}=    RW.GCP.ServiceHealth.Filter Status Results
    ...    ${history}
    ...    ${SECONDS_IN_PAST}
    ...    products=${PRODUCT_LIST}
    ${metric}=    Evaluate    len($filtered)

Get Number Of GCP Incidents For 2 Products In 2 Regions
    ${history}=    RW.GCP.ServiceHealth.Get Status Json
    ${filtered}=    RW.GCP.ServiceHealth.Filter Status Results
    ...    ${history}
    ...    ${SECONDS_IN_PAST}
    ...    products=${PRODUCT_LIST}
    ...    regions=${REGION}
    ${metric}=    Evaluate    len($filtered)

Get Large Amount Of History Of Incidents
    ${history}=    RW.GCP.ServiceHealth.Get Status Json
    ${filtered}=    RW.GCP.ServiceHealth.Filter Status Results
    ...    ${history}
    ...    31556952
    ...    products=Google Cloud Console
    ...    check_ongoing=False
    Log    ${filtered}
    ${metric}=    Evaluate    len($filtered)
