# Kubernetes Postgres Query
This codebundle leverages the Kubernetes API and running pod to execute psql queries (using kubectl exec). These codebundles also capture the duration of the query. 

## SLI
This codebundle uses a Kubernetes workload to run a postgres SQL query and pushes the query result as an SLI metric. The workload will run the query and return the result from stdout, along with the timing of the query. 

Example configuration: 
```
## Variable Configuration
Context: default # this depends on what the context is called in the kubeconfig
Workload Name: statefulset/mydb-1
Workload Namespace: my-database-namespace
Workload Container: database # Often there are many containers in the database pod
Query: SELECT COUNT(*) FROM user_table; # The targeted database is configured as a secret
Hostname: localhost
Distribution: Kubernetes
```

## TaskSet
This codebundle uses a Kubernetes workload to run a postgres SQL query and returns the results in an aligned table with headers as a report. The workload will run the query and return the result from stdout, along with the timing of the query. 

Example configuration: 
```
## Variable Configuration
Context: default # this depends on what the context is called in the kubeconfig
Workload Name: statefulset/mydb-1
Workload Namespace: my-database-namespace
Workload Container: database # Often there are many containers in the database pod
Query: SELECT id,firstname,lastname FROM user_table ORDER BY lastname ASC; # The targeted database is configured as a secret
Hostname: localhost
Distribution: Kubernetes
```


## Use Cases
- When you have a postgres deployment or equivalent (eg: patroni) deployment in your kubernetes cluster and would like to use a query result as a metric without publicly exposing the database.
- If you want to periodically check and measure an attribute of your database, such as slow queries, memory usage, index efficiency, etc.

## Requirements
- A kubeconfig with adequate access permissions to the workload running the query. For Kubernetes RBAC, the service account needs `create` permission on the `pods/exec` resource. 
- For SLIs, a postgres compatible query which returns a single result row. If you're getting multiple rows consider aggregating them via COUNT, MAX, SUM, GROUP BY, etc.
- A kubernetes workload with `psql` binary as part of its image that can access the database within the constraints of its network. You can use the same workload as the one running the database.
- The `hostname`, `user`, `password`, `database name` credentials, where the user has adequate permissions to perform the query on the desired table.

## TODO
- [ ] Add additional documentation or examples