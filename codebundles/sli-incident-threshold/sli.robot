*** Settings ***
Metadata          Author    Jonathan Funk
Documentation     An SLI which monitors another SLI that's submitting a 0-1 health score and when that health score falls below a threshold, will immediately trigger a taskset.
...               When this SLI detects a rate below the threshold rate it submits a 1 to denote a signal was sent before returning to 0 when the monitored SLI is healthy.
Force Tags        SLI    Alert    Threshold
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
    ${THRESHOLD_VALUE}=    RW.Core.Import User Variable    THRESHOLD_VALUE
    ...    type=string
    ...    description=The value searched for in the SLI metrics that indicates a successful / healthy state.
    ...    pattern=(\d+?)
    ...    example=1
    ...    default=1
    ${EXPECTED_THRESHOLD_RATE}=    RW.Core.Import User Variable    EXPECTED_THRESHOLD_RATE
    ...    type=string
    ...    description=The rate of successes within the data set inspected. If the actual rate is lower than this a TaskSet will be triggered.
    ...    pattern=(\d+?)
    ...    example=A rate 0.25 indicates that within a time range of X and success value of Y, we see Y in X's data set 25% of the time.
    ...    default=0.25
    ${ALERT_TASKSET}=    RW.Core.Import User Variable    ALERT_TASKSET
    ...    type=string
    ...    description=The name of the SLX containing the TaskSet to run when the monitored SLI is classified as an alert.
    ...    pattern=\w*
    ...    example=my-awesome-slx
    ${NO_RESULT_DEFAULT}=    RW.Core.Import User Variable    NO_RESULT_DEFAULT
    ...    type=string
    ...    description=The default value assumed when no results are returned by the monitored SLI.
    ...    pattern=(\d+?)
    ...    default=1
    ...    example=1
    Set Suite Variable    ${WORKSPACE_NAME}    ${WORKSPACE_NAME}
    Set Suite Variable    ${SLX_NAME}    ${SLX_NAME}
    Set Suite Variable    ${HISTORY_WINDOW}    ${HISTORY_WINDOW}
    Set Suite Variable    ${RESOLUTION}    ${RESOLUTION}
    Set Suite Variable    ${THRESHOLD_VALUE}    ${THRESHOLD_VALUE}
    Set Suite Variable    ${EXPECTED_THRESHOLD_RATE}    ${EXPECTED_THRESHOLD_RATE}
    Set Suite Variable    ${ALERT_TASKSET}    ${ALERT_TASKSET}
    Set Suite Variable    ${NO_RESULT_DEFAULT}    ${NO_RESULT_DEFAULT}

*** Tasks ***
Check If SLI Within Incident Threshold
    ${metric_data}=    RW.RunWhen.Papi.Get SLX Metrics
    ...    workspace=${WORKSPACE_NAME}
    ...    slx_name=${SLX_NAME}
    ...    history=${HISTORY_WINDOW}
    ...    resolution=${RESOLUTION}
    ${success_rate}=    RW.Utils.Rate Of Occurence
    ...    data=${metric_data}
    ...    count_value=${THRESHOLD_VALUE}
    ...    default_value=${NO_RESULT_DEFAULT}
    ${signal}=    Evaluate    1 if ${success_rate} < ${EXPECTED_THRESHOLD_RATE} else 0
    IF    ${signal}
        Log    Alert signal set - running TaskSet ${ALERT_TASKSET}
        ${rsp}=    RW.RunWhen.Papi.Run Taskset
        ...    workspace=${WORKSPACE_NAME}
        ...    slx_name=${ALERT_TASKSET}
    END
    RW.Core.Push Metric    ${signal}


