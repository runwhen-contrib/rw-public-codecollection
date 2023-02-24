# Kubernetes Postgres Query
This codebundle leverages the Kubernetes API and running pod to run a series of postgres triage tasks (using kubectl exec). 

## TaskSet
This codebundle provides a report of Kubernetes reosurce health along with Postgres health, using a Kubernetes workload to run muiltiple postgres SQL qieries. 

Example configuration: 
```

```


## Use Cases
- When you have a postgres deployment or equivalent (eg: patroni) deployment in your kubernetes cluster and would like to use a query result as a metric without publicly exposing the database.
- If you want to periodically check and measure an attribute of your database, such as slow queries, memory usage, index efficiency, etc.

## Requirements
- A kubeconfig with adequate access permissions to the workload running the query. For Kubernetes RBAC, the service account needs `create` permission on the `pods/exec` resource. 
- A kubernetes workload with `psql` binary as part of its image that can access the database within the constraints of its network. You can use the same workload as the one running the database.
- The `hostname`, `user`, `password`, `database name` credentials, where the user has adequate permissions to perform the query on the desired table.

## TODO
- [ ] Add additional documentation or examples