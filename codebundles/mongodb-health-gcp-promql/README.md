# MongoDB Health Google Managed Prometheus (promql)
This codebundle provides an opinionated healthcheck on mongoDB instances. It requires that the Mongodb Prometheus exporter (by Percona) is configured appropriately and that metrics are being sent to Google Managed Prometheus. 
 

## Service Level Indicator
The SLI codebundle provides a composite health check which provides a score between 0 (unhealthy) and 1 (healthy). Any value between 0 and 1 indicates that one of the following health checks produced a score of 0 for its individual check. The score is derived by adding up the value of each test and dividing by the total number of tests. 

Evaluations performed in this healthcheck: 

- Instance Status: Are the expected amount of members running for each instance?
- Connection Utilization Rate: Is the current connection utilization (current/max) above the desired threshold for any instance?
- Member Health: Are any of the members reporting an unhealthy state?
- Replication Lag: Is the largest replication for any cluster above the desired threshold?
- Queue Size: Is size of the queue (reads or writes) above the desired threshold?
- Assertion Rate: Is the rate of assertions over the last 5m above the desired threshold for any instance?

This SLI does support measing health across multiple instances and often reports the Max value obtained across instances. The PROMQL_FILTER can be used to add specific labels for query filtering as necessary. 

> For those not looking for composite scores, the (gcp-opssuite-promql)[https://docs.runwhen.com/public/v/codebundles/gcp-opssuite-promql] codebundle can be used to create specific SLIs for any specific metric. 

## Use Cases
### Use Case: SLI: MongoDB Community Edition Health for All Instances in a Kubernetes Namespace
The following use case provides an example configuration in which the SLI can be used to provide a composite score across multiple mongodb clusters in the same namespace. 

> For a full walkthough on the setup of an environment with MongoDB Community Edition, Percona MongoDB Prometheus Exporter, and Google Mangaged Prometheus, please view [the complete docs located here](https://docs.runwhen.com/public/use-cases/kubernetes-environments/measuring-mongodb-health-with-promql). 

- Example MongoDB Community edition object: 
```
apiVersion: mongodbcommunity.mongodb.com/v1
kind: MongoDBCommunity
metadata:
  name: sandbox-mongodb
  namespace: mongodb-test
spec:
  members: 3
  type: ReplicaSet
  version: "4.4.0"
  security:
    authentication:
      modes: ["SCRAM"]
  users:
    - name: my-user
      db: admin
      passwordSecretRef: # a reference to the secret that will be used to generate the user's password
        name: my-user-password
      roles:
        - name: clusterAdmin
          db: admin
        - name: userAdminAnyDatabase
          db: admin
      scramCredentialsSecretName: my-scram
  additionalMongodConfig:
    storage.wiredTiger.engineConfig.journalCompressor: zlib
    net.maxIncomingConnections: 1000
```

- Example Percona MongoDB Prometheus Exporter:
```
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: mongodb-exporter
  namespace: mongodb-test
spec:
  releaseName: mongodb-test-exporter
  chart:
    spec:
      chart: prometheus-mongodb-exporter
      # https://github.com/prometheus-community/helm-charts/blob/main/charts/prometheus-mongodb-exporter/values.yaml
      version: 3.1.2
      sourceRef:
        kind: HelmRepository
        name: prometheus-community
        namespace: flux-system
  interval: 5m
  values:
    image:
      pullPolicy: IfNotPresent
      repository: percona/mongodb_exporter
      tag: "0.37.0"
    mongodb:
      uri: "mongodb://my-user:SuperSecretPassword@sandbox-mongodb-0.sandbox-mongodb-svc.mongodb-test.svc.cluster.local:27017"
```

- Example codebundle configuration: 
```
configProvided:
  - name: PROMQL_FILTER
    value: namespace="mongodb-test"
  - name: CONNECTION_UTILIZATION_THRESHOLD
    value: '80'
  - name: MAX_LAG
    value: '60'
  - name: MAX_ASSERTION_RATE
    value: '1'
  - name: PROJECT_ID
    value: [gcp-project-id]
  - name: MAX_QUEUE_SIZE
    value: '0'
secretsProvided:
  - name: ops-suite-sa
    workspaceKey: [secret-name]
servicesProvided:
  - name: curl
    locationServiceName: curl-service.shared
```
With the example above, a score of less than 1 would be produced if any of the conditions are true: 
- Any members are not running
- Any instance member is returning an unhealthy state
- The amount of active connections vs max is 80% or greater
- Any instance has a replication lag of 60s or larger
- Any instance has assertions are being generated at a rate of 1/s or greater
- Any instance has any read or write requests waiting in the queue

## Requirements
### Version Details
This codebundle was tested with MongoDB Community Edition Kubernetes Operator, with MongoDB versions: 
- 4.4.0
- 6.0.5

Along with the Percona MongoDB Prometheus Exporter chart version 3.1.2 and image version v0.37.0

### Service Account Requirements  
This codebundle requires a service account and accompanying json key uploaded as a secret to the workspace.

The service account should have the following roles: 
- Logs Viewer - `roles/logging.viewer`
- Monitoring Viewer - `roles/monitoring.viewer`

> Note: It's likely that only the Monitoring Viewer role is required for promql queries, but both roles are helpful when using other gcp-opssuite* codebundles. 

Please see the [documentation for creating service accounts](https://cloud.google.com/iam/docs/creating-managing-service-accounts)

## Helpful Resources
- https://www.mongodb.com/docs/v4.2/reference/replica-states/
- https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus-mongodb-exporter
- https://github.com/mongodb/mongodb-kubernetes-operator/blob/master/README.md