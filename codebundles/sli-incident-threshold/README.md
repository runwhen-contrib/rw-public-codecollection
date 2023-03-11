# SLI Incident Threshold
This codebundle allows you to monitor another SLI and trigger a TaskSet when the expected rate of a SLI value falls below a specified threshold.

## SLI
Depending on your observability needs, the Multi-Window Multi-Burn algorithm + SLO error budgets approach may not apply to your use case. In those cases you can use this codebundle to create an incident threshold based on another SLI. A query will be performed on the monitored SLI's metrics for a given time window and resolution, and then the presence of a success value will be checked. For example: fetch 1 hour of metric data at 5 minute intervals, for the monitored SLI; a `0` means failure and `1` means healthy. If we set the success value to `1` and a rate of `1.0` (100%) then when any failure occurs in the monitored SLI, this codebundle will immediately trigger the given TaskSet.

### Use Case: SLI: Trigger a slack message when my API health check fails
For our public API, it's uptime is critical, so we can monitor its health check and send a slack message to a team channel whenever the health check fails.

```
configProvided:
  - name: WORKSPACE_NAME
    value: 'tutorial-ws'
  - name: SLX_NAME
    value: public-api-health
  - name: HISTORY_WINDOW
    value: '1h'
  - name: RESOLUTION
    value: '15m'
  - name: SUCCESS_VALUE
    value: 1
  - name: EXPECTED_SUCCESS_RATE
    value: 1.0
  - name: INCIDENT_TASKSET
    value: tool-slackmsg
```
> Because the window in this example is `1h` and our success rate is `100%` then if 1 error is detected in the metric data, the incident will be detected for the next `1h` while it persists in the window. Consider this when determining your window, resolution and expected success rate in relation to how you want the TaskSet to behave.

## Requirements
- The name of the SLI you want to monitor
- Verify that the SLI submits a consistent value that denotes a success (eg: 0 is always good, 1 is always good, etc) as you'll need to set this as your `success value`
- The name of the workspace the SLX and SLI reside in

## TODO
- [ ] Add additional notes for tweaking threshold models to get the desired behaviour
- [ ] Add operand setting to handle other SLI styles
