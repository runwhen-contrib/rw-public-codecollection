# ArgoCD Health Check
## SLI
Periodically checks a list of objects deployed by ArgoCD are in a healthy state. A healthy state is determined if the object has available replicas. A metric value of 1 is returned when healthy and 0 when unhealthy.

## Use Cases
- Apply a periodic health check to the following list of objects deployed by Argo CD:
```
[
    "argocd-applicationset-controller",
    "argocd-dex-server",
    "argocd-notifications-controller",
    "argocd-redis",
    "argocd-repo-server",
    "argocd-server",
    "argocd-application-controller",
]
```

## Requirements
- A `kubeconfig` with adequate access permissions to the execution workload running the query.
- The `namespace` to check in.

## TODO
- [ ] Add additional documentation