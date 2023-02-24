# Kubernetes Patroni Replica Lag
Manage lagging patroni cluster replica members by monitoring their lag and actioning them by reinitializing them with the accompanying taskset. Using the Kubernetes API, users can setup the maximum allowed lag of replicas as an SLI and attach an SLO to it which triggers an alert when a member passes the allowed lag threshold.

## SLI
The sli will use `kubectl` to access the Patroni API via `patronictl` in a workload pod with access to the patroni instance and fetch the state of the patroni cluster, eg:
```
[{'Cluster': 'mypatroni-1',
  'Host': '0.0.0.0',
  'Member': 'mypatroni-1-0',
  'Role': 'Leader',
  'State': 'running',
  'TL': 12},
 {'Cluster': 'mypatroni-1',
  'Host': '0.0.0.0',
  'Lag in MB': 7,
  'Member': 'mypatroni-1-1',
  'Role': 'Replica',
  'State': 'running',
  'TL': 12}]
```

In this case, the SLI will report the maximum lag value `7` as the SLI value. By configuring an SLO with for example a threshold of `5` this will cause an alert to fire if persistent for long enough to burn budget. You can automatically remediate severly lagging replicas which are unable catch up by reinitializing them. See the taskset use case below.

## TaskSet
The taskset grabs a list of replicas who's lag (represented in MB) is beyond a configured tolerance and reinitialize them so that they're caught up to the leader. When a patroni replica member becomes too laggy, it may be unable to catch up in its replication process - this could be considered an unhealthy state.


## Use Cases
### Use Case: SLI: Measure Max Replica Lag In Kubernetes
In this use case, can monitor a Patroni cluster's maximum lag (in MB) in Kubernetes by using a configuration similar to:
```
configProvided:
  - name: PATRONI_RESOURCE_NAME
    value: statefulset/mypatroni-1
  - name: NAMESPACE
    value: mydata
  - name: CONTEXT
    value: default
  - name: DISTRIBUTION
    value: Kubernetes
```

### Use Case: TaskSet: Autoheal Laggy Replica Member
In this use case, users can use the taskset to reinitialize a laggy replica which is unable to catch up.
Given the following config:
```
  - name: LAG_TOLERANCE
    value: '5'
  - name: PATRONI_RESOURCE_NAME
    value: statefulset/mypatroni-001
  - name: NAMESPACE
    value: mydata
  - name: CONTEXT
    value: default
  - name: DISTRIBUTION
    value: Kubernetes
  - name: DOC_LINK
    value: ''
```

In this use case, if the lag is detected to be greater than 5MB, the TaskSet will automatically reinitialize the replicas. 


## Requirements
- A kubeconfig with `get, list` access on Patroni objects in the chosen namespace, along with the verb `create` on resource `pods/exec`
- The resource name of the Kubernetes workload object
- The `namespace` where the wokload is located
- A `context` to use from the `kubeconfig`
- A selected `Distribution` to fit best for your cluster, eg: GKE, OpenShift, etc.
- Determine a `lag tolerance` in MB which classifies what replicas need to be actioned
