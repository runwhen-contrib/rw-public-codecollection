*** Settings ***
Library           RW.Sysdig
Suite Setup       Suite Initialization

*** Keywords ***
Suite Initialization
    ${SYSDIG_TOKEN}=    Evaluate    RW.platform.Secret("token", """%{SYSDIG_TOKEN}""")
    ${SYSDIG_HEADERS}=    Evaluate    RW.platform.Secret("token", """%{SYSDIG_HEADERS}""")
    Set Suite Variable    ${SYSDIG_HEADERS}    ${SYSDIG_HEADERS}
    Set Suite Variable    ${SYSDIG_TOKEN}    ${SYSDIG_TOKEN}
    Set Suite Variable    ${SYSDIG_URL}    %{SYSDIG_URL}
    Set Suite Variable    ${SYSDIG_PROMQL_URL}    %{SYSDIG_PROMQL_URL}
    Set Suite Variable    ${SYSDIG_QUERY}    %{SYSDIG_QUERY}

*** Tasks ***
Fetch Metric List
    ${rsp}=    RW.Sysdig.Get Metrics List    token=${SYSDIG_TOKEN}    sdc_url=${SYSDIG_URL}
    Log    ${rsp}

Fetch Filtered Metric List
    ${rsp}=    RW.Sysdig.Get Metrics List    token=${SYSDIG_TOKEN}    sdc_url=${SYSDIG_URL}    metric_filter=cpu
    Log    ${rsp}
    ${rsp}=    RW.Sysdig.Get Metrics List    token=${SYSDIG_TOKEN}    sdc_url=${SYSDIG_URL}    metric_filter=fs
    Log    ${rsp}
    ${rsp}=    RW.Sysdig.Get Metrics List    token=${SYSDIG_TOKEN}    sdc_url=${SYSDIG_URL}    metric_filter=kube
    Log    ${rsp}

Fetch Specific Metric Details
    ${rsp}=    RW.Sysdig.Get Metrics Dict    token=${SYSDIG_TOKEN}    sdc_url=${SYSDIG_URL}    metric_filter=fs.used.percent
    Log    ${rsp}

Fetch Metric
    ${rsp}=    RW.Sysdig.Get Metric Data    token=${SYSDIG_TOKEN}    sdc_url=${SYSDIG_URL}
    ...    query_str=[{"id": "cpu.used.percent", "aggregations": {"time": "timeAvg", "group": "avg"}}]
    Log    ${rsp}

Fetch Metric With Filter
    ${rsp}=    RW.Sysdig.Get Metric Data    token=${SYSDIG_TOKEN}    sdc_url=${SYSDIG_URL}
    ...    query_str=[{"id": "kubernetes.resourcequota.persistentvolumeclaims.used", "aggregations": {"time": "timeAvg", "group": "avg"}}]
    Log    ${rsp}

Fetch Promql Data
    ${rsp}=    RW.Sysdig.Promql Query    api_url=${SYSDIG_PROMQL_URL}    query=${SYSDIG_QUERY}    optional_headers=${SYSDIG_HEADERS}
    ...    step=30s
    ...    seconds_in_past=600
    ${data}=    Set Variable    ${rsp["data"]}
    ${transform}=    RW.Sysdig.Transform Data    ${data}    Last
