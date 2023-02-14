# Kubernetes Namespace Health Check
Check the health of a Kubernetes namespace and its objects. 

# SLI 
Periodically inspect the state of a Kubernetes namespace to determine if its score is 1 (healthy) or 0 (unhealthy). Supports values that are between 0 and 1 depending on the result of each test. The suite of checks considered are:
- how many **events** of a specific type (e.g. Warning) and of a certain age (e.g. 5m) are counted
- how many **container restarts** a certain age (e.g. 5m) are counted
- are any pods not ready

Thresholds can be configured for the total amount of **events** or **container** restarts that are considered to still be healthy. Any pod that is NotReady is considered unhealthy. 

Each of these checks receives a score of 1 (healthy) or 0 (unhealthy), and they are added up and divided by the total number of checks. This means that a namespace can have a health score between 0 and 1 depending on the types of issues that are occuring. 

Example configuration: 
```
export DISTRIBUTION=Kubernetes
export CONTEXT=default
export NAMESPACE=flux-system
export EVENT_AGE=5m
export EVENT_TYPE=Warning
export EVENT_THRESHOLD=0
export CONTAINER_RESTART_AGE=5m
export CONTAINER_RESTART_THRESHOLD=0
```

With the example above, a namespace would be be considerd a 0 (unhealthy) if there are any container restarts within 5m, any Warning events within 5m, and any pod is NotReady. If all pods are ready but Warning events or container restarts occur within 5m, it could receive a score of 0.33 or 0.66. If the namespace has zero Warning events, zero container restarts, and all pods are Ready, the score is 1 (healthy). 

## TaskSet
This taskset runs general troubleshooting checks against all applicable objects in a namespace, checks error events, and searches pod logs for error entries.

## Requirements
- kubeconfig with appropriate RBAC permissions to `get` `pods` and `events` on desired namespaces


## TODO
- [ ] Optimize the multi-namespace configuration. 