# Kubernetes Patroni Replica Lag
Manage lagging patroni cluster replica members by monitoring their lag and actioning them by reinitializing them with the accompanying taskset. Using the Kubernetes API, you can setup the maximum allowed lag of replicas as an SLI and attach an SLO to it which triggers an alert when a member passes the allowed lag threshold.
The taskset will grab a list of replicas who's lag is beyond a configured tolerance and reinitialize them so that they're caught up to the leader. When a patroni replica member becomes too laggy, it may be unable to catch up in its replication process - this could be considered an unhealthy state. You can reinitialize an unhealthy replica using `patronictl` which is done for you when using the taskset.

The sli will use kubectl to access the Patroni API via `patronictl` in a workload pod with access to the patroni instance and fetch the state of the patroni cluster, eg:
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


## Use Cases
### Use Case: SLI: Measure Max Replica Lag In Kubernetes
You can monitor a Patroni cluster's maximum lag in Kubernetes by using a configuration similar to:
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

Adjusting this according to your `namespace`, `distribution` and the name of the `patroni resource`
> Plus you'll need a `kubeconfig` with service account permissions to access the workload capable of running `patronictl`

### Use Case: TaskSet: Autoheal Laggy Replica Member
You can use the taskset to reinitialize a laggy replica which is unable to catch up.
Given the following config 
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

Adjusting this according to your `namespace`, `distribution` and the name of the `patroni resource`
> Plus you'll need a `kubeconfig` with service account permissions to access the workload capable of running `patronictl`

The taskset will use a Kubernetes workload to run `patronictl` and determine replicas past a lag threshold. In this example if our threshold was `5` then the replica `mypatroni-1-X` would be detected as unhealthy and require remediation. The taskset will perform a reinitialization of `mypatroni-1-X` in the cluster and fetch the state afterwards to add to a report. Once reinitialization has finished the replica should be in a healthy state and caught up in replication.


## Requirements
- A `kubeconfig` with read access to the Patroni workload in the Kubernetes cluster
- The resource name of the Kubernetes workload object
- The `namespace` where the wokload is located
- A `context` to use from the `kubeconfig`
- A selected `Distribution` to fit best for your cluster, eg: GKE, OpenShift, etc.
- Determine a `lag tolerance` which classifies what replicas need to be actioned

## TODO
- [ ] Add additional documentation