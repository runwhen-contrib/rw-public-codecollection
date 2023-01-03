# Kubernetes Namespace Health Check

## SLI
Periodically inspect the state of a Kubernetes namespace to determine if its score is 1 (healthy) or 0 (unhealthy). The suite of checks considered are:
- does the namespace have pod restarts
- does the namespace have recent non-info events

## Use Cases
- Measure the health of your namespaces in your cluster.

## Requirements
- A kubeconfig with get/list access on event objects in the chosen namespace.
- A chosen `namespace` and `context` to use from the kubeconfig
- An accessible `Prometheus` instance.
- An oauth `token` to authenticate with the Prometheus REST API.

## TODO
- [ ] Add additional documentation