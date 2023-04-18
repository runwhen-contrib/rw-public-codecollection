# Kubernetes Helm Health
The `k8s-helm-health` codebundle checks for helm related resources within the Kubernetes cluster to surface up potential issues. 

## TaskSet
This TaskSet looks for any helmreleases in the specified namespace within the configured context and: 
- prints a list of every helmrelease and it's status
- prints a list of all helm release version details
- prints a list of helm releases that have mismatched versions (e.g. last attempted version doesn't match the running version)
- prints all helmreleases that are not healthy along with the associated error messages

## Requirements
- A kubeconfig with `get` permissions to on the objects/namespaces that are involved in the query.


## TODO
- Add additional rbac and kubectl resources and use cases
- Add an SLI for measuing helmrelease health
- Add additional troubleshooting tasks as use cases evolve