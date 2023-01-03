# Kubernetes Daemonset Healthcheck

## SLI
Periodically checks the state of a daemonset and returns a score of 1 (healthy) or 0 (unhealthy). For a daemonset to be considered healthy it must:

- Should not be above the allowed max unavailable count
- Have 0 misscheduled pods
- Have at least the minimum allowed pods
- All scheduled pods should ready and available, indicating successful rollouts

## Use Cases
- Check your vault csi driver is healthy and properly deployed across your nodes.

## Requirements
- A kubeconfig with get/list access on daemonset objects in the chosen namespace.
- A chosen `namespace` and `context` to use from the kubeconfig
- A `daemonset name` to monitor within the chosen `namespace`.

## TODO
- [ ] Add additional documentation