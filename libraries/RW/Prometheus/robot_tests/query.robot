*** Settings ***
Library           RW.Prometheus
Library           RW.Core
Suite Setup       Suite Initialization

*** Keywords ***
Suite Initialization
    RW.Core.Import Service    curl
    Set Suite Variable    ${PROM_HOSTNAME}    %{PROM_HOSTNAME}
    Set Suite Variable    ${PROM_QUERY}    %{PROM_QUERY}
    # Set Suite Variable    ${PROM_TEST_LABEL}    %{PROM_TEST_LABEL}
    # Set Suite Variable    ${PROM_AGGR_QUERY}    %{PROM_AGGR_QUERY}
    ${PROM_OPT_HEADERS}=    Evaluate    RW.platform.Secret("optional_headers", """%{PROM_OPT_HEADERS}""")
    Set Suite Variable    ${PROM_OPT_HEADERS}    ${PROM_OPT_HEADERS}

*** Tasks ***
Instant Query
    ${rsp}=    RW.Prometheus.Query Instant    api_url=${PROM_HOSTNAME}    query=${PROM_QUERY}    optional_headers=${PROM_OPT_HEADERS}
    Log    ${rsp}

Instant Query With Service
    ${rsp}=    RW.Prometheus.Query Instant
    ...    api_url=${PROM_HOSTNAME}
    ...    query=${PROM_QUERY}
    ...    optional_headers=${PROM_OPT_HEADERS}
    ...    target_service=${curl}
    ${transform}=    RW.Prometheus.Transform Data
    ...    data=${rsp}
    ...    method=Last
    ...    no_result_value=0.0
    ...    no_result_overwrite=Yes
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
    ...    no_result_value=0.0
    ...    no_result_overwrite=Yes
    Log    ${rsp}
    Log    ${transform}

Get Range Data And Sum
    ${rsp}=    RW.Prometheus.Query Range    api_url=${PROM_HOSTNAME}    query=${PROM_QUERY}    optional_headers=${PROM_OPT_HEADERS}
    ...    step=30s
    ...    seconds_in_past=36000
    ${data}=    Set Variable    ${rsp["data"]}
    ${transform}=    RW.Prometheus.Transform Data    ${data}    Sum
    ...    no_result_value=0.0
    ...    no_result_overwrite=Yes
    Log    ${rsp}
    Log    ${transform}

Get Range Data And Get Most Recent
    ${rsp}=    RW.Prometheus.Query Range    api_url=${PROM_HOSTNAME}    query=${PROM_QUERY}    optional_headers=${PROM_OPT_HEADERS}
    ...    step=30s
    ...    seconds_in_past=36000
    ${data}=    Set Variable    ${rsp["data"]}
    # The last value in the ordered list is the most recent prom data value
    ${transform}=    RW.Prometheus.Transform Data    ${data}    Last
    ...    no_result_value=0.0
    ...    no_result_overwrite=Yes
    Log    ${rsp}
    Log    ${transform}

Run Transform Query With Step
    ${rsp}=    RW.Prometheus.Query Instant    api_url=${PROM_HOSTNAME}    query=${PROM_AGGR_QUERY}    optional_headers=${PROM_OPT_HEADERS}
    ...    step=30s
    # ...    seconds_in_past=36000
    ${data}=    Set Variable    ${rsp["data"]}
    # The last value in the ordered list is the most recent prom data value
    ${transform}=    RW.Prometheus.Transform Data    ${data}    Raw
    ...    no_result_value=0.0
    ...    no_result_overwrite=Yes
    Log    ${rsp}
    Log    ${transform}

Run Transform Query Without Step
    ${rsp}=    RW.Prometheus.Query Instant    api_url=${PROM_HOSTNAME}    query=${PROM_AGGR_QUERY}    optional_headers=${PROM_OPT_HEADERS}
    # ...    step=30s
    # ...    seconds_in_past=36000
    ${data}=    Set Variable    ${rsp["data"]}
    # The last value in the ordered list is the most recent prom data value
    ${transform}=    RW.Prometheus.Transform Data    ${data}    Raw
    ...    no_result_value=0.0
    ...    no_result_overwrite=Yes
    Log    ${rsp}
    Log    ${transform}
