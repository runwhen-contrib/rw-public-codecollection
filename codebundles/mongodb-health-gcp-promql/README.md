# MongoDB Health Google Managed Prometheus (promql)
This codebundle provides an opinionated healthcheck on mongoDB instances. It requires that the mongodb Prometheus exporter is configured appropriately and that metrics are being sent to Google Managed Prometheus. 


## Service Level Indicator
- mongodb_up
- mongodb_connections{state="available"} ~= 0 
- mongodb_op_counters (in ops/s)
- mongodb_replset_member_state
- 

## Use Cases
### Use Case: SLI: MongoDB Instance Health


## Requirements
### Service Account Requirements  
This codebundle requires a service account and accompanying json key uploaded as a secret to the workspace.

The service account should have the following roles: 
- Logs Viewer - `roles/logging.viewer`
- Monitoring Viewer - `roles/monitoring.viewer`

> Note: It's likely that only the Monitoring Viewer role is required for promql queries, but both roles are helpful when using other gcp-opssuite* codebundles. 

Please see the [documentation for creating service accounts](https://cloud.google.com/iam/docs/creating-managing-service-accounts)

## Helpful Resources
