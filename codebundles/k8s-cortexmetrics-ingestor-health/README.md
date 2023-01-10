# Kubernetes Cortex Metrics Ingester Health

## SLI
Periodically checks the state of the cortex metrics ingestors and returns a score of 1 (healthy) or 0 (unhealthy). This SLI performs the query by executing a `kubectl exec` into a Kubernetes resource, leveraging existing Kubernetes API authentication. For the ingesters to be considered healthy they must:

- Be considered "ACTIVE" in the ingester ring as published by the http api endpoint `/ring`
- Have as many "ACTIVE" ingester ring members as specified in the SLI configuration variable EXPECTED_RING_MEMBERS

## TaskSet
Queries the state of ingestors and returns the state of each along with the latest timestamp . This TaskSet performs the query by executing a `kubectl exec` into a Kubernetes resource, leveraging existing Kubernetes API authentication. 

## Requirements
- A kubeconfig with `get, list` access on cortex objects in the chosen namespace, along with the verb `create` on resource `pods/exec`
- A chosen `namespace` and `context` to use from the kubeconfig
- A cortex pod resource that has access to the `ring` api endpoint to exec into within the chosen `namespace` (often the distributor pods)

## TODO
- [ ] Add additional documentation
- [ ] Add additional taskset checks 