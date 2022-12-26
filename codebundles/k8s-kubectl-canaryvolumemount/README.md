# Kubernetes kubectl Canary Volume Mount

## TaskSet
An SLI which periodically creates a job which lists the contents of a directory on a pvc, if the list command succeeds than the SLI
returns a score of 1, otherwise a 0 when it fails.

## Use Cases
- Validate that system storage is working and can be provisioned on the cluster.

## Requirements

## TODO
- [ ] Add additional documentation