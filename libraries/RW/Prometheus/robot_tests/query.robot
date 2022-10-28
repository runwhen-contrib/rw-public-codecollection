*** Settings ***
Library           RW.Prometheus
Suite Setup       Suite Initialization

*** Keywords ***
Suite Initialization
    Set Suite Variable    ${PROM_HOSTNAME}    %{PROM_HOSTNAME}
    Set Suite Variable    ${PROM_QUERY}    %{PROM_QUERY}
    Set Suite Variable    ${PROM_TEST_LABEL}    %{PROM_TEST_LABEL}
    Set Suite Variable    ${PROM_AGGR_QUERY}    %{PROM_AGGR_QUERY}
    ${PROM_OPT_HEADERS}=    Evaluate    RW.platform.Secret("optional_headers", """%{PROM_OPT_HEADERS}""")
    Set Suite Variable    ${PROM_OPT_HEADERS}    ${PROM_OPT_HEADERS}

*** Tasks ***
Instant Query
    ${rsp}=    RW.Prometheus.Query Instant    api_url=${PROM_HOSTNAME}    query=${PROM_QUERY}    optional_headers=${PROM_OPT_HEADERS}
    Log    ${rsp}

Range Query
    ${rsp}=    RW.Prometheus.Query Range    api_url=${PROM_HOSTNAME}    query=${PROM_QUERY}    optional_headers=${PROM_OPT_HEADERS}
    ...    step=30s
    ...    seconds_in_past=36000
    Log    ${rsp}

Labels Query
    ${rsp}=    RW.Prometheus.List Labels    api_url=${PROM_HOSTNAME}    optional_headers=${PROM_OPT_HEADERS}
    Log    ${rsp}

Label Values Query
    ${rsp}=    RW.Prometheus.Query Label    api_url=${PROM_HOSTNAME}    label=${PROM_TEST_LABEL}    optional_headers=${PROM_OPT_HEADERS}
    Log    ${rsp}

Get Range Data And Average
    ${rsp}=    RW.Prometheus.Query Range    api_url=${PROM_HOSTNAME}    query=${PROM_QUERY}    optional_headers=${PROM_OPT_HEADERS}
    ...    step=30s
    ...    seconds_in_past=36000
    ${data}=    Set Variable    ${rsp["data"]}
    ${transform}=    RW.Prometheus.Transform Data    ${data}    Average
    Log    ${rsp}
    Log    ${transform}

Get Range Data And Sum
    ${rsp}=    RW.Prometheus.Query Range    api_url=${PROM_HOSTNAME}    query=${PROM_QUERY}    optional_headers=${PROM_OPT_HEADERS}
    ...    step=30s
    ...    seconds_in_past=36000
    ${data}=    Set Variable    ${rsp["data"]}
    ${transform}=    RW.Prometheus.Transform Data    ${data}    Sum
    Log    ${rsp}
    Log    ${transform}

Get Range Data And Get Most Recent
    ${rsp}=    RW.Prometheus.Query Range    api_url=${PROM_HOSTNAME}    query=${PROM_QUERY}    optional_headers=${PROM_OPT_HEADERS}
    ...    step=30s
    ...    seconds_in_past=36000
    ${data}=    Set Variable    ${rsp["data"]}
    # The last value in the ordered list is the most recent prom data value
    ${transform}=    RW.Prometheus.Transform Data    ${data}    Last
    Log    ${rsp}
    Log    ${transform}

Run Transform Query With Step
    ${rsp}=    RW.Prometheus.Query Instant    api_url=${PROM_HOSTNAME}    query=${PROM_AGGR_QUERY}    optional_headers=${PROM_OPT_HEADERS}
    ...    step=30s
    # ...    seconds_in_past=36000
    ${data}=    Set Variable    ${rsp["data"]}
    # The last value in the ordered list is the most recent prom data value
    ${transform}=    RW.Prometheus.Transform Data    ${data}    Raw
    Log    ${rsp}
    Log    ${transform}

Run Transform Query Without Step
    ${rsp}=    RW.Prometheus.Query Instant    api_url=${PROM_HOSTNAME}    query=${PROM_AGGR_QUERY}    optional_headers=${PROM_OPT_HEADERS}
    # ...    step=30s
    # ...    seconds_in_past=36000
    ${data}=    Set Variable    ${rsp["data"]}
    # The last value in the ordered list is the most recent prom data value
    ${transform}=    RW.Prometheus.Transform Data    ${data}    Raw
    Log    ${rsp}
    Log    ${transform}
