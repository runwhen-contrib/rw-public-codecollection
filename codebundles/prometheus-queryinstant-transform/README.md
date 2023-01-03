# Prometheus Instant Query

## SLI
Run a PromQL query against Prometheus instant query API, perform a provided transform, and return the result.

## Use Cases
- If you want to monitor the number of heartbeats failing across nodes, provided your kube_state metrics are submitted to the prometheus instance, then you can enter this query, which will give you a count of failing heartbeats across the node fleet:
`((max(sum by(condition) (kube_node_status_condition{condition!="Ready", status="false"}))+min(kube_node_status_condition{condition="Ready", status="true"}))*-1) + count( sum( kube_node_status_condition ) by (condition) )`

## Requirements

## TODO
- [ ] Add additional documentation