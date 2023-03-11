*** Settings ***
Metadata          Author    Jonathan Funk
Documentation     An SLI which monitors another SLI that's submitting a 0-1 health score and when that health score falls below a threshold, will immediately trigger a taskset.
...               When this SLI detects an incident it submits a 1 to denote a signal was sent before returning to 0 when the monitored SLI is healthy.
Force Tags        SLI    Incident    Threshold
Suite Setup       Suite Initialization
Library           RW.Core
Library           RW.Rest
Library           RW.Utils
Library           RW.RunWhen.Papi

*** Keywords ***
Suite Initialization
    ${WORKSPACE_NAME}=    RW.Core.Import User Variable    WORKSPACE_NAME
    ...    type=string
    ...    description=The workspace the SLI resides in.
    ...    pattern=\w*
    ...    example=my-awesome-ws
    ...    default=my-awesome-ws
    ${SLX_NAME}=    RW.Core.Import User Variable    SLX_NAME
    ...    type=string
    ...    description=The SLX the SLI is attached to.
    ...    pattern=\w*
    ...    example=my-awesome-slx
    ...    default=my-awesome-slx
    ${HISTORY_WINDOW}=    RW.Core.Import User Variable    HISTORY_WINDOW
    ...    type=string
    ...    description=The history window to fetch from the metric store.
    ...    pattern=((\d+?)d)?((\d+?)h)?((\d+?)m)?((\d+?)s)?
    ...    example=1h
    ...    default=1h
    ${RESOLUTION}=    RW.Core.Import User Variable    RESOLUTION
    ...    type=string
    ...    description=The resolution that determines the number of data points.
    ...    pattern=((\d+?)d)?((\d+?)h)?((\d+?)m)?((\d+?)s)?
    ...    example=5m
    ...    default=5m
    ${SUCCESS_VALUE}=    RW.Core.Import User Variable    SUCCESS_VALUE
    ...    type=string
    ...    description=The value searched for in the SLI metrics that indicates a successful / healthy state.
    ...    pattern=(\d+?)
    ...    example=1
    ...    default=1
    ${EXPECTED_SUCCESS_RATE}=    RW.Core.Import User Variable    EXPECTED_SUCCESS_RATE
    ...    type=string
    ...    description=The rate of successes within the data set inspected. If the actual rate is lower than this a TaskSet will be triggered.
    ...    pattern=(\d+?)
    ...    example=A rate 0.25 indicates that within a time range of X and success value of Y, we see Y in X's data set 25% of the time.
    ...    default=0.25
    ${INCIDENT_TASKSET}=    RW.Core.Import User Variable    INCIDENT_TASKSET
    ...    type=string
    ...    description=The name of the SLX containing the TaskSet to run when the monitored SLI is classified as an incident.
    ...    pattern=\w*
    ...    example=my-awesome-slx
    Set Suite Variable    ${WORKSPACE_NAME}    ${WORKSPACE_NAME}
    Set Suite Variable    ${SLX_NAME}    ${SLX_NAME}
    Set Suite Variable    ${HISTORY_WINDOW}    ${HISTORY_WINDOW}
    Set Suite Variable    ${RESOLUTION}    ${RESOLUTION}
    Set Suite Variable    ${SUCCESS_VALUE}    ${SUCCESS_VALUE}
    Set Suite Variable    ${EXPECTED_SUCCESS_RATE}    ${EXPECTED_SUCCESS_RATE}
    Set Suite Variable    ${INCIDENT_TASKSET}    ${INCIDENT_TASKSET}

*** Tasks ***
Check If SLI Within Incident Threshold
    ${metric_data}=    RW.RunWhen.Papi.Get SLX Metrics
    ...    workspace=${WORKSPACE_NAME}
    ...    slx_name=${SLX_NAME}
    ...    history=${HISTORY_WINDOW}
    ...    resolution=${RESOLUTION}
    ${success_rate}=    RW.Utils.Rate Of Occurence
    ...    data=${metric_data}
    ...    count_value=${SUCCESS_VALUE}
    ${signal}=    Evaluate    1 if ${success_rate} < ${EXPECTED_SUCCESS_RATE} else 0
    IF    ${signal}
        Log    Incident signal set - running TaskSet
        ${rsp}=    RW.RunWhen.Papi.Run Taskset
        ...    workspace=${WORKSPACE_NAME}
        ...    slx_name=${SLX_NAME}
    END
    RW.Core.Push Metric    ${signal}


