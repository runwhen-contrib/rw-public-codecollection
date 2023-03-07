# Kubernetes kubectl Run
A highly generic codebundle used for running bare kubectl commands (or equivalent binaries) and presenting the stdout as a report. This allows users to take their commonly used `kubectl` triage commands for their workloads and paste them into the codebundle config, both automating and version controlling their triage process as code, which can then be shared with their team.

## TaskSet
### Use Case: TaskSet: Fetch Pod Error Logs
We can generate a report containing pod logs who's entries have `Exception` or `Error` in the log line. Given the config:

```
configProvided:
  - name: DISTRIBUTION
    value: Kubernetes
  - name: KUBECTL_COMMAND
    value: >-
      kubectl logs deployment/my-app -n default -n my-namespace --tail=200 | grep -E -i "(Exception|Error)"
```

Which will fetch us the last 200 logs lines and parse them for issues and present those in the taskset report for us to view on the platform.

## Use Cases

## Requirements
- A kubeconfig with appropriate RBAC permissions to perform the desired command.

## TODO
- [ ] link to kubeconfig rbac doc
- [ ] Add additional documentation