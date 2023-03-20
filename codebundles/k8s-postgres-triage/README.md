# Kubernetes Postgres Triage
This codebundle leverages the Kubernetes API and a running database pod to triage a database cluster. It leverages standard `kubectl` commands to inspect the deployed resources (such as returning the status of each element, custome resource, and so on) along with using `kubectl exec` to run `psql` commands that can provide additional information such as the running configuration, query statistics, and so on.   

## TaskSet
This codebundle provides a report of Kubernetes resource health along with Postgres health, with the following tasks:  
- Standard Kubernetes Resources: Outputs all resources associated with the desired labels, namespace, and context with abbreviated output. 
- Describe Custom Resources: Optional. Searches for custom resources based on a search string (e.g. postgres) and adds the output of `kubectl describe` of these resources to the report. 
- Get Pod Logs & Events: Fetches Kubernetes events and logs that are related to the desired labels. 
- Get Pod Resource Utilization: Fetchs the output of `kubectl top` for all pods and containers that are related to the desired labels. 
- Get Running Configuration: Uses `kubectl exec` to fetch the running config of the psql instance and adds the contents of that file to the report. 
- Get Patroni Output: Uses `kubectl exec` to fetch the output of `patronictl list`. 
- Get DB Stastics: Uses `kubectl exec` to execute psql queries that can provide insights in to long running queries and other helpful database level statistics. PSQL queries are configurable.  


## Use Cases
This codebundle can be used as a low-level information collection tool when RunWhen Map users want more details about all resources related a database instance.

### Use Case: TaskSet: Triage CrunchyData Postgres Instance
In order to triage a CrunchyData postgres cluster that is deployed by the crunchydata postgres operator, the following TaskSet configuration might apply:

```
configProvided:
  - name: INCLUDE_CUSTOM_RESOURCES
    value: 'Yes'
  - name: CRD_FILTER
    value: postgres
  - name: LOG_LINES
    value: '100'
  - name: QUERY
    value: >-
      SELECT (total_exec_time / 1000 / 60) as total, (total_exec_time/calls) as
      avg, query FROM pg_stat_statements ORDER BY 1 DESC LIMIT 100;
  - name: CONTEXT
    value: [kubeconfig_context]
  - name: RESOURCE_LABELS
    value: postgres-operator.crunchydata.com/cluster=[cluster-name]
  - name: WORKLOAD_NAME
    value: >-
      -l postgres-operator.crunchydata.com/role=[primary-label],postgres-operator.crunchydata.com/cluster=[cluster-name]
  - name: NAMESPACE
    value: [kubernetes_namespace]
  - name: WORKLOAD_CONTAINER
    value: [database_container_name]
  - name: HOSTNAME
    value: ''
  - name: DISTRIBUTION
    value: Kubernetes

```
> Because the CrunchyData operator doesn't require the local pod to authenticate, the hostname  and pg_username was left blank, and the pg_password was set to an arbitrary non_null value (like 'test'). This configuration will vary across deployments and should be validated prior to TaskSet configuration. This can easily be validated by running something like `kubectl exec [primary_pod_name] -c [database container] -n [namespace] -- /bin/bash -c "PGPASSWORD=$pg_password psql -U $pg_username -d [database_name] -c '\l '"`. Since the codebundle uses `kubectl exec`, users can use their own terminals to determine the right configuration that works with their specific instance. 

#### Additional CrunchyData Postgres Configurations
The following CrunchyData postgres cluster additional configuration was used to deploy the instance with support for `pg_stat_statements`: 

```
apiVersion: postgres-operator.crunchydata.com/v1beta1
kind: PostgresCluster
metadata:
  name: [cluster-name]
  namespace: [namespace]
spec:
  image: registry.developers.crunchydata.com/crunchydata/crunchy-postgres:ubi8-13.9-0
  postgresVersion: 13
  patroni:
    dynamicConfiguration:
      postgresql:
        parameters:
          shared_preload_libraries: "pg_stat_statements"
  [additional instance configuration]
  ...
```

Since this specific configuration was using the `pg_stat_statements` extension, this needed to be enabled on the desired database: 
```
# Either as one line; 
kubectl exec [primary_pod_name] -c [database container] -n [namespace] -- /bin/bash -c "PGPASSWORD=$pg_password psql -U $pg_username -d [database_name] -c 'CREATE EXTENSION pg_stat_statements'"`

#Or: 
kubectl exec -it [primary_pod_name] -c [database container] -n [namespace] -- /bin/bash
bash-4.4$ psql 
psql (13.9)
Type "help" for help.

postgres=# \c [database]
You are now connected to database "[database]" as user "postgres".
[database]=# CREATE EXTENSION pg_stats_statements
```
#### Kubernetes RBAC Configuration
As this triage TaskSet performs a number of discovery tasks across standard resources, custom resources, and runtime database configuration details, the following RBAC configurations were used in testing this TaskSet: 
```
## Cluster Roles - Needed to search for specific resource types (could possible be scoped down further)
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  namespace: viewer
  name: crd-viewer
rules:
- apiGroups: ["apiextensions.k8s.io"]
  resources: ["customresourcedefinitions"]
  verbs: ["get", "watch", "list"]


## Cluster Role binding
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: [service_account]-crd-viewer-rb
  namespace: [namespace]]
subjects:
- kind: ServiceAccount
  name: [service_account]-sa
  namespace: [namespace]
roleRef:
  kind: ClusterRole
  name: crd-viewer
  apiGroup: rbac.authorization.k8s.io

## Service Account Role
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: [namespace]
  name: [service-account]-role
rules:
- apiGroups: [""] # "" indicates the core API group
  resources: ["pods", "pods/log", "events", "configmaps", "services", "replicationcontrollers"]
  verbs: ["get", "watch", "list"]
- apiGroups: ["batch"]
  resources: ["*"]
  verbs: ["get", "watch", "list"]
- apiGroups: ["apps"]
  resources: ["*"]
  verbs: ["get", "watch", "list", "delete"]
- apiGroups: ["autoscaling"]
  resources: ["*"]
  verbs: ["get", "watch", "list", "delete"]
- apiGroups: [""] 
  resources: ["pods/exec"]
  verbs: ["create"]
- apiGroups: ["postgres-operator.crunchydata.com"]
  resources: ["*"]
  verbs: ["get", "watch", "list"]
- apiGroups: ["metrics.k8s.io"]
  resources: ["*"]
  verbs: ["get", "watch", "list"]

## Rolebinding
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: [service-account]-rb
  namespace: [namespace]
subjects:
- kind: ServiceAccount
  name: [service-account]-sa
  namespace: [namespace]
roleRef:
  kind: Role
  name: [service-account]-role
  apiGroup: rbac.authorization.k8s.io

```

## Requirements
- A kubeconfig, service account, and rbac with adequate access to: 
    - `"get","list","watch"` on most resources within the namespace (core api group, batch, apps, autoscaling) to successfully run `kubectl get all`
    - `"create"` on `pods/exec` for pods within the namespace to run commands within the postgres container
    - `"get" ,"list","watch"` all necessary custom resources within the namespace
    - `"get","list","watch"` all custom resource definitions within the cluster determine *which* custom resources to search for (if using operators)
    - `"get","list","watch"` on the specific custom resources (if using operators)
    - `"get","list","watch"` for `metrics.k8s-io` to retrieve output from `kuebctl top`

- A kubernetes workload with `psql` binary as part of its image that can access the database within the constraints of its network. You can use the same workload as the one running the database.
- The `hostname`, `user`, `password`, `database name` credentials, where the user has adequate permissions to perform the query on the desired table.

## TODO
- [ ] Consider adding additional troubleshooting queries 
- [ ] Consider analysing the output to provide recommendations (e.g. # of replicas, resource configuraitons, etc)
- [ ] Consider how to select more useful items of interest, or at least omit thinkgs like the ugly metadata that comes in with the CRD
