# Kubernetes kubectl Canary Volume Mount

## SLI
An SLI which periodically creates a job which lists the contents of a directory on a pvc, if the list command succeeds than the SLI
returns a score of 1, otherwise a 0 when it fails.

## Use Cases
- Validate that system storage is working and can be provisioned on the cluster.

## Requirements
- A kubeconfig with get/list access on deployment, pod, and PVC objects in the chosen namespace.
- A chosen `namespace` and `context` to use from the kubeconfig.

## TODO
- [ ] Add additional documentation