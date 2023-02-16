# GCP Operations Suite PromQL
This codebundle leverages the [Google Managed Prometheus](https://cloud.google.com/stackdriver/docs/managed-prometheus) service and the Promethues Query API for Google customers to query metrics in their projects using promql.   
 
## SLI
Performs a metric query using PromQL statement on the Ops Suite API and pushes it to the RunWhen platform.  

## Use Cases
### Use Case: SLI: Query Prometheus for Kubernetes Deployment Health in a Namespace
This example demonstrates how to use this codebundle to capture an SLI about the health of a specific Kubernetes deployment. See [kube-state-metrics](https://github.com/kubernetes/kube-state-metrics/blob/main/docs/deployment-metrics.md) for more detail. 

Since a query such as `kube_deployment_status_condition{namespace="[namespace]"}` returns a value for each possible status of every deployment condition in the namespace (such as `Available=true,false,unknown` or `Progressing=true,false,unknown`), we will use a query that adds up any deployments that are NOT `Available=true` or `Progressing=true`. This query could look like `sum(kube_deployment_status_condition{namespace="[namespace]", condition=~"Available|Progressing", status=~"false|unknown"})`. Since this should add up any bad state, a number greater than `0` is considered bad. 

Example SLI codebundle configuration:

```
PROJECT_ID: gcp-project-id
PROMQL_STATEMENT: sum(kube_deployment_status_condition{namespace="[namespace]", condition=~"Available|Progressing", status=~"false|unknown"})
TRANSFORM=Raw
DATA_COLUMN=1
NO_RESULT_OVERWRITE=No # Not needed as each status returns a 1 or 0 
```

**An example SLO for this would state**:   
"In any 30 day period, the SLI should be `equal to` `0` approximately `99.5`% of the time. This implies an error budget of 22 minutes." 

With an SLO set to 0, the error budget will burn if **ANY** deployment is in an unhealthy state as reported by `kube-state-metrics`. 

A few additional resources on Kubernetes deployment management: 
- https://unofficial-kubernetes.readthedocs.io/en/latest/concepts/workloads/controllers/deployment/
- https://maelvls.dev/deployment-available-condition/


### Use Case: SLI: Monitoring Crossplane Managed Resource Health with Kube State Metrics
See [here](https://docs.runwhen.com/public/use-cases/kubernetes-environments/crossplane-resources-health-check) for a very detailed use case on monitoring custom resources (using [Crossplane](https://www.crossplane.io/) managed resources as the example). 

Review the documentation above to configure monitoring of Custom Resources with Kube State Metrics. Once completed, the following SLI codebundle configuration can be used to return  a count of our GKE Cluster, Kubernetes Objects, or Helm Releases that are unhealthy: 
```
PROJECT_ID: gcp-project-id
PROMQL_STATEMENT: >-
      sum(kube_crd_crossplane_cluster_ready{status="False"}) +
      sum(kube_crd_crossplane_kubernetes_object_ready{status="False"}) +
      sum(kube_crd_crossplane_helm_release_ready{status="False"})
TRANSFORM: Raw                 #Choose Raw since the promql query will perform all desired transformations
DATA_COLUMN: '1'               #The promql query provides a single result, so the data column is always 1 
NO_RESULT_OVERWRITE: 'No'      #Our query should always return a result, so this is not required
NO_RESULT_VALUE: '0'           #Not used since we aren't enabling no_result_overwrite
```
**An example SLO for this would state**:   
"In any 30 day period, the SLI should be `equal to` `0` approximately `99.5`% of the time. This implies an error budget of 22 minutes." 

With an SLO set to 0, the error budget will burn if **ANY** Crossplane resource is in an unhealthy state as reported by `kube-state-metrics`. 

## Requirements  
### Service Account Requirements  
This codebundle requires a service account and accompanying json key uploaded as a secret to the workspace.

The service account should have the following roles: 
- Logs Viewer - `roles/logging.viewer`
- Monitoring Viewer - `roles/monitoring.viewer`

> Note: It's likely that only the Monitoring Viewer role is required for promql queries, but both roles are helpful when using other gcp-opssuite* codebundles. 

Please see the [documentation for creating service accounts](https://cloud.google.com/iam/docs/creating-managing-service-accounts)


## TODO