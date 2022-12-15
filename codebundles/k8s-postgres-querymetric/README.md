# Kubernetes Postgres Query Metric

## SLI
This codebundle uses a Kubernetes workload to run a postgres SQL query and pushes the query result as an SLI metric.
During execution, the SQL query should be passed to a Kubernetes workload that has access to the `psql` binary.
The workload will run the query and return the result from stdout.

## Use Cases
- When you have a postgres deployment or equivalent (eg: patroni) deployment in your kubernetes cluster and would like to use a query result as a metric without publicly exposing the database.
- If you want to periodically check and measure an attribute of your database, such as slow queries, memory usage, index efficiency, etc.

## Requirements
- A kubeconfig with adequate access permissions to the execution workload running the query.
- A postgres compatible query which returns a single result row. If you're getting multiple rows consider aggregating them via COUNT, MAX, SUM, GROUP BY, etc.
- A kubernetes workload with `psql` binary as part of its image that can access the database within the constraints of its network. You can use the same workload as the one running the database.
- The `hostname`, `user`, `password`, `database name` credentials, where the user has adequate permissions to perform the query on the desired table.

## TODO
- [ ] Add additional documentation