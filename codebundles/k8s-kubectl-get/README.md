# Kubernetes kubectl get
The `kubectl get` codebundles run an arbitrary `kubectl get` command that fetches objects with json output. The results from the desired command are returned, filtered, and computed using json output and jmespath as directed by the configuration. 

## SLI
The SLI and provides a single metric. First, the `kubectl get [parameters]` command can be input as desired with the results returned as json. The results can be further refined as needed through the `SEARCH_FILTER` and `CALCULATION_FIELD` configuration options, though most users will likely want to just copy/paste helpful `kubectl get` commands that they are familiar with (such as `kubectl get pods -l app=[labelname]`). 

The SLI supports the following calculations: 
- **Count**: Returns the number of items returned from the query.
- **Sum**: Sums up all values in the specified `calculation field` for all returned objects. 
- **Average**: Provides the average of all values in the specified  `calculation field` for all returned objects. 

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

### Use Case: SLI: Count unhealthy Crossplane resources
See [here](https://docs.runwhen.com/public/use-cases/kubernetes-environments/crossplane-resources-health-check) for a very detailed use case on monitoring custom resources (using Crossplane managed resources as the example). 

In this use case, we can query a cluster for the status of Crossplane managed resources (GKE clusters, Kubernetes Objects, Helm Releases): 
```
DISTRIBUTION: Kubernetes
KUBECTL_COMMAND: kubectl get clusters,objects,releases
CALCULATION: Count
CALCULATION_FIELD: ''
SEARCH_FILTER: >-
      status.conditions[?(type==`Ready` && status!=`True`) || (type==`Synced` &&
      status!=`True`)]
```

With this configuration, users could now apply an SLO to fire off alerts or TaskSets if any of these objects are considered NotReady). 


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
CALCULATION='Count'
SEARCH_FILTER='status.conditions[?type==`Ready` && status!=`True`]'
KUBECTL_COMMAND='kubectl get helmreleases.helm.toolkit.fluxcd.io --all-namespaces'
CALULATION_FIELD=''
```

With this configuration, users could now apply an SLO to fire off alerts or TaskSets if this number is abnormal (since failing helmreleases might be affecting other other services). 


### Use Case: SLI: Count all Kubernetes API Services
In this use case, we can query a  cluster for count of API Services: 
```
CALCULATION='Count'
SEARCH_FILTER=''
KUBECTL_COMMAND='kubectl get apiservice'
CALULATION_FIELD=''
```

### Use Case: SLI: Count all Kubernetes API Services that are **NOT** "Ready"
In this use case, we can query a  cluster for API Services that are NOT in a Ready state: 
```
CALCULATION='Count'
SEARCH_FILTER='status.conditions[?type==`Ready` && status!=`True`]'
KUBECTL_COMMAND='kubectl get apiservice'
CALULATION_FIELD=''
```

With this configuration, users could now apply an SLO to fire off alerts or TaskSets if this number is abnormal (since a failing apiservice might be affecting other other services).

### Use Case: SLI: Count all Services without Endpoints
In this use case, we can query a namespace for all services that do not have an associated endpoint: 
```
CALCULATION='Count'
SEARCH_FILTER='!subsets'
KUBECTL_COMMAND='kubectl get endpoints -n [namespace]'
CALULATION_FIELD=''
```
> It may be desirable to have some services that do not have endpoints, but and the associated SLO could account for this, but mmany general application deployments will have a service associated with one or more endpoints. 


## Requirements
- A kubeconfig with `get` permissions to on the objects/namespaces that are involved in the query.

## Resources
- JMESPath is used to help in the filtering of results and calculation fields. A useful pattern is to run your commands with the json output option (e.g. `kubectl get pods -n [mynamespace] -o json`) and copy the output into https://jmespath.org/ for testing of various search filters. 


## TODO
- Add additional rbac and kubectl resources and use cases