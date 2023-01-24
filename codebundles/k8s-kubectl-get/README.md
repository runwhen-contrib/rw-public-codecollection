# Kubernetes kubectl get
The `kubectl get` codebundles run an arbitrary `kubectl get` command that fetches objects with json output. The results from the desired command are returned, filtered, and computed using json output and jmespath as directed by the configuration. 

## SLI
The SLI and provides a single metric. First, the `kubectl get ...` command can be input as desired with the results returned as json. The resultset can be further refined as needed through the `SEARCH_FILTER` and `CALCULATION_FIELD` configuration options, though most users 
will likely want to just copy/paste helpful `kubectl get` commands that they are familiar with (such as `kubectl get pods -l app=[labelname]`). 

The SLI supports the following calculations: 
- Count: Returns the number of items returned from the query.
- Sum: Sums up all values in the specified `calculation field` for all returned objects. 
- Average: Provides the average of all values in the specified  `calculation field` for all returned objects. 

## Use Cases
### Use Case: SLI: Query all Certificates that are **NOT** "Ready" in a namespace
In this use case, we can query a namespace for all certificate objects. This first configuration would return a count of certificates in the namespace: 
```
CALCULATION='Count'
SEARCH_FILTER=''
KUBECTL_COMMAND='kubectl get certificates --namespace [my-namespace]'
CALULATION_FIELD=''
```

This SLI might not be all too helpful in determining health, but it can be expanded to search for Certificates with a ready status that is **NOT** "True": 
```
CALCULATION='Count'
SEARCH_FILTER='status.conditions[?type==`Ready` && status!=`True`]'
KUBECTL_COMMAND='kubectl get certificates --namespace [my-namespace]'
CALULATION_FIELD=''
```

With this configuration, users could now apply an SLO to fire off alerts or TaskSets if this number is greater than 0 (since Certificates that aren't ready could cause problems). 

### Use Case: SLI: Sum, up all container restarts in a namespace
In this use case, we can query a namespace all pods and add up every container restart: 
```
CALCULATION='Sum'
SEARCH_FILTER=''
KUBECTL_COMMAND='kubectl get pods --namespace [my-namespace]'
CALULATION_FIELD='status.containerStatuses[].restartCount'
```

With this configuration, users could now apply an SLO to fire off alerts or TaskSets if this number is abnormal (since a high amount of container restarts could indicate an issue). 


### Use Case: SLI: Count all Flux HelmReleases that are **NOT** "Ready"
In this use case, we can query a  cluster for HelmReleases that are NOT in a Ready state: 
```
CALCULATION='Sum'
SEARCH_FILTER='status.conditions[?type==`Ready` && status!=`True`]'
KUBECTL_COMMAND='kubectl get helmreleases.helm.toolkit.fluxcd.io --all-namespaces'
CALULATION_FIELD=''
```

With this configuration, users could now apply an SLO to fire off alerts or TaskSets if this number is abnormal (since failing helmreleases might be affecting other other services). 


### Use Case: SLI: Count all Kubernetes API Services
In this use case, we can query a  cluster for count of API Services: 
```
CALCULATION='Sum'
SEARCH_FILTER=''
KUBECTL_COMMAND='kubectl get apiservice'
CALULATION_FIELD=''
```

### Use Case: SLI: Count all Kubernetes API Services that are **NOT** "Ready"
In this use case, we can query a  cluster for API Services that are NOT in a Ready state: 
```
CALCULATION='Sum'
SEARCH_FILTER='status.conditions[?type==`Ready` && status!=`True`]'
KUBECTL_COMMAND='kubectl get apiservice'
CALULATION_FIELD=''
```

With this configuration, users could now apply an SLO to fire off alerts or TaskSets if this number is abnormal (since a failing apiservice might be affecting other other services).

## Requirements
- A kubeconfig with `get` permissions to on the objects/namespaces that are involved in the query.

## Resources
JMESPath is used to help in the filtering of results and calculation fields. A useful pattern is to run your commands with the json output option (e.g. `kubectl get pods -n [mynamespace] -o json`) and copy the output into https://jmespath.org/ for testing of various search filters. 


## TODO
- [ ] Add additional documentation