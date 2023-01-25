![](docs/GitHub_Banner.jpg)

# RunWhen Public Codecollection
This repository is the primary public codecollection that is to be used within the RunWhen platform. It contains codebundles that can be used in SLIs, SLOs, and TaskSets. 

Please see the **[contributing](CONTRIBUTING.md)** and **[code of conduct](CODE_OF_CONDUCT.md)** for details on adding your contributions to this project. 

Documentation for each codebundle is maintained in the README.md alongside the robot code and is published at [https://docs.runwhen.com/public/v/codebundles/](https://docs.runwhen.com/public/v/codebundles/). 


## Codebundle Index
| Folder Name | Type | Path | Documentation |
|---|---|---|---|
| argocd-healthcheck | SLI | [sli.robot](./codebundles/argocd-healthcheck/sli.robot) |      Check the health of ArgoCD platfrom by checking the availability of its underlying Deployments and StatefulSets. |
| artifactory-ok | SLI | [sli.robot](./codebundles/artifactory-ok/sli.robot) |      Checks an Artifactory instance health endpoint to determine its operational status. |
| aws-account-limit | TaskSet | [runbook.robot](./codebundles/aws-account-limit/runbook.robot) |      Retrieve all recently created AWS accounts. |
| aws-account-limit | SLI | [sli.robot](./codebundles/aws-account-limit/sli.robot) |      Retrieve the count of all AWS accounts in an organization. |
| aws-billing-costsacrosstags | TaskSet | [runbook.robot](./codebundles/aws-billing-costsacrosstags/runbook.robot) |      Creates a report of AWS line item costs filtered to a list of tagged resources |
| aws-billing-tagcosts | SLI | [sli.robot](./codebundles/aws-billing-tagcosts/sli.robot) |      Monitors AWS cost and usage data for the latest billing period. |
| aws-cloudformation-stackevents-count | SLI | [sli.robot](./codebundles/aws-cloudformation-stackevents-count/sli.robot) |      Retrieve the number of detected AWS CloudFormation stack events over a given history |
| aws-cloudformation-triage | TaskSet | [runbook.robot](./codebundles/aws-cloudformation-triage/runbook.robot) |      Triage and troubleshoot various issues with AWS CloudFormation |
| aws-cloudwatch-logquery-rowcount-zeroerror | SLI | [sli.robot](./codebundles/aws-cloudwatch-logquery-rowcount-zeroerror/sli.robot) |      Retrieve binary result from an AWS CloudWatch Insights query. |
| aws-cloudwatch-logquery | SLI | [sli.robot](./codebundles/aws-cloudwatch-logquery/sli.robot) |      Retrieve number of results from an AWS CloudWatch Insights query. |
| aws-cloudwatch-metricquery-dashboard | TaskSet | [runbook.robot](./codebundles/aws-cloudwatch-metricquery-dashboard/runbook.robot) |      Creates a URL to a AWS CloudWatch metrics dashboard with a running query. |
| aws-cloudwatch-metricquery | SLI | [sli.robot](./codebundles/aws-cloudwatch-metricquery/sli.robot) |      Retrieve the result of an AWS CloudWatch Metrics Insights query. |
| aws-cloudwatch-tagmetricquery | SLI | [sli.robot](./codebundles/aws-cloudwatch-tagmetricquery/sli.robot) |      Retrieve aggregate results from multiple AWS Cloudwatch Metrics Insights queries ran against tagged resources. |
| aws-ec2-securitycheck | TaskSet | [runbook.robot](./codebundles/aws-ec2-securitycheck/runbook.robot) |      Performs a suite of security checks against a set of AWS EC2 instances. |
| aws-s3-stalecheck | TaskSet | [runbook.robot](./codebundles/aws-s3-stalecheck/runbook.robot) |      Identify stale AWS S3 buckets, based on last modified object timestamp. |
| aws-vm-triage | TaskSet | [runbook.robot](./codebundles/aws-vm-triage/runbook.robot) |      Triage and troubleshoot performance and usage of an AWS EC2 instance |
| cert-manager-expirations | SLI | [sli.robot](./codebundles/cert-manager-expirations/sli.robot) |      Retrieve number of expired TLS certificates managed by cert-manager within a given window. |
| cert-manager-healthcheck | SLI | [sli.robot](./codebundles/cert-manager-healthcheck/sli.robot) |      Check the health of pods deployed by cert-manager. |
| datadog-system-load | SLI | [sli.robot](./codebundles/datadog-system-load/sli.robot) |      Retrieve a DataDog instance's "System Load" metric |
| discord-send-message | TaskSet | [runbook.robot](./codebundles/discord-send-message/runbook.robot) |      Send a message to a Discord channel. |
| dns-latency | SLI | [sli.robot](./codebundles/dns-latency/sli.robot) |      Check DNS latency for Google Resolver. |
| elasticsearch-health | SLI | [sli.robot](./codebundles/elasticsearch-health/sli.robot) |    Check Elasticsearch cluster health |
| gcp-opssuite-logquery-dashboard | TaskSet | [runbook.robot](./codebundles/gcp-opssuite-logquery-dashboard/runbook.robot) |      Generate a link to the GCP Log Explorer. |
| gcp-opssuite-logquery | SLI | [sli.robot](./codebundles/gcp-opssuite-logquery/sli.robot) |      Retrieve the number of results of a GCP Log Explorer query. |
| gcp-opssuite-metricquery | SLI | [sli.robot](./codebundles/gcp-opssuite-metricquery/sli.robot) |      Performs a metric query using a Google MQL statement on the Ops Suite API |
| gcp-opssuite-promql | SLI | [sli.robot](./codebundles/gcp-opssuite-promql/sli.robot) |      Performs a metric query using a PromQL statement on the Ops Suite API |
| gcp-serviceshealth | SLI | [sli.robot](./codebundles/gcp-serviceshealth/sli.robot) |      This codebundle sets up a monitor for a specific region and GCP Product, which is then periodically checked for |
| github-actions-workflowtiming | SLI | [sli.robot](./codebundles/github-actions-workflowtiming/sli.robot) |      Monitors the average timing of a github actions workflow file within a repo |
| github-get-repos-latency | TaskSet | [runbook.robot](./codebundles/github-get-repos-latency/runbook.robot) |      Create a new issue in GitHub Issues. |
| github-get-repos-latency | SLI | [sli.robot](./codebundles/github-get-repos-latency/sli.robot) |      Check GitHub latency by getting a list of repo names. |
| github-status-components | SLI | [sli.robot](./codebundles/github-status-components/sli.robot) |      Check status of the GitHub platform (https://www.githubstatus.com/) for a specified set of GitHub service components. |
| github-status-incidents | SLI | [sli.robot](./codebundles/github-status-incidents/sli.robot) |      Check for unresolved incidents related to GitHub services, and provides a count of ongoing incidents as a metric. |
| github-status-maintenances | SLI | [sli.robot](./codebundles/github-status-maintenances/sli.robot) |      Retrieve number of upcoming Github platform maintenances over a given window. |
| gitlab-availability | TaskSet | [runbook.robot](./codebundles/gitlab-availability/runbook.robot) |      Troubleshoot issues with GitLab server availability. |
| gitlab-availability | SLI | [sli.robot](./codebundles/gitlab-availability/sli.robot) |      Check availability of a GitLab server. |
| gitlab-get-repos-latency | SLI | [sli.robot](./codebundles/gitlab-get-repos-latency/sli.robot) |      Check GitLab latency by getting a list of repo names. |
| grafana-health | SLI | [sli.robot](./codebundles/grafana-health/sli.robot) |      Check Grafana server health. |
| hello-world | TaskSet | [runbook.robot](./codebundles/hello-world/runbook.robot) |      Basic Hello-World TaskSet |
| http-latency | SLI | [sli.robot](./codebundles/http-latency/sli.robot) |      Measure HTTP latency against a given URL. |
| http-ok | SLI | [sli.robot](./codebundles/http-ok/sli.robot) |      Check if an HTTP request against a URL fails or times out of a given latency window. |
| jira-search-issues-latency | TaskSet | [runbook.robot](./codebundles/jira-search-issues-latency/runbook.robot) |      Create an issue in Jira. |
| jira-search-issues-latency | SLI | [sli.robot](./codebundles/jira-search-issues-latency/sli.robot) |      Check Jira latency when searching issues by current user. |
| k8s-cortexmetrics-ingestor-health | TaskSet | [runbook.robot](./codebundles/k8s-cortexmetrics-ingestor-health/runbook.robot) |        Uses kubectl to query the state of a ingestor ring. Returns the json of injester id, status and timestamp. |
| k8s-cortexmetrics-ingestor-health | SLI | [sli.robot](./codebundles/k8s-cortexmetrics-ingestor-health/sli.robot) |        Uses kubectl to query the state of a ingestor ring and determine if it's healthy. Returns 1 if healthy, 0 if unhealthy. |
| k8s-daemonset-healthcheck | SLI | [sli.robot](./codebundles/k8s-daemonset-healthcheck/sli.robot) |        Checks that the current state of a daemonset is healthy and returns a score of either 1 (healthy) or 0 (unhealthy). |
| k8s-decommission-workloads | TaskSet | [runbook.robot](./codebundles/k8s-decommission-workloads/runbook.robot) |      Searches a namespace for matching objects and provides the commands to decommission them. |
| k8s-kubectl-apiserverhealth | SLI | [sli.robot](./codebundles/k8s-kubectl-apiserverhealth/sli.robot) |      Check the health of a Kubernetes API server using kubectl. |
| k8s-kubectl-canaryvolumemount | SLI | [sli.robot](./codebundles/k8s-kubectl-canaryvolumemount/sli.robot) |        Creates an adhoc one-shot job which mounts a PVC as a canary test, which is polled for success before being torn down. |
| k8s-kubectl-eventquery | SLI | [sli.robot](./codebundles/k8s-kubectl-eventquery/sli.robot) |        Returns the number of events with matching messages as an SLI metric. |
| k8s-kubectl-get | SLI | [sli.robot](./codebundles/k8s-kubectl-get/sli.robot) |        This codebundle runs a kubectl get command that produces a value and pushes the metric. |
| k8s-kubectl-run | TaskSet | [runbook.robot](./codebundles/k8s-kubectl-run/runbook.robot) |      This codebundle runs an arbitrary kubectl command and writes the stdout to a report. |
| k8s-kubectl-sanitycheck | TaskSet | [runbook.robot](./codebundles/k8s-kubectl-sanitycheck/runbook.robot) |      Used for troubleshooting the shellservice-based kubectl service |
| k8s-kubectl-top | SLI | [sli.robot](./codebundles/k8s-kubectl-top/sli.robot) |      Retreieve aggregate data via kubectl top command. |
| k8s-namespace-healthcheck | SLI | [sli.robot](./codebundles/k8s-namespace-healthcheck/sli.robot) |        Scores the health of a Kubernetes namespace by examining both namespace events and Prometheus metrics. |
| k8s-patroni-healthcheck | SLI | [sli.robot](./codebundles/k8s-patroni-healthcheck/sli.robot) |      Uses kubectl (or equivalent) to query the state of a patroni cluster and determine if it's healthy. |
| k8s-postgres-query | TaskSet | [runbook.robot](./codebundles/k8s-postgres-query/runbook.robot) |        Runs a postgres SQL query and pushes the returned result into a report. |
| k8s-postgres-query | SLI | [sli.robot](./codebundles/k8s-postgres-query/sli.robot) |        Runs a postgres SQL query and pushes the returned query result as an SLI metric. |
| k8s-triage-deploymentreplicas | TaskSet | [runbook.robot](./codebundles/k8s-triage-deploymentreplicas/runbook.robot) |      Triages issues related to a deployment's replicas. |
| k8s-triage-patroni | TaskSet | [runbook.robot](./codebundles/k8s-triage-patroni/runbook.robot) |      Taskset to triage issues related to patroni. |
| k8s-triage-statefulset | TaskSet | [runbook.robot](./codebundles/k8s-triage-statefulset/runbook.robot) |      A taskset for troubleshooting issues for StatefulSets and their related resources. |
| k8s-troubleshoot-deployment | TaskSet | [runbook.robot](./codebundles/k8s-troubleshoot-deployment/runbook.robot) |      A taskset for troubleshooting general issues associated with typical kubernetes deployment resources. |
| k8s-troubleshoot-namespace | TaskSet | [runbook.robot](./codebundles/k8s-troubleshoot-namespace/runbook.robot) |      This taskset runs general troubleshooting checks against all applicable objects in a namespace, checks error events, and searches pod logs for error entries. |
| msteams-send-message | TaskSet | [runbook.robot](./codebundles/msteams-send-message/runbook.robot) |      Send a message to an MS Teams channel. |
| opsgenie-alert | TaskSet | [runbook.robot](./codebundles/opsgenie-alert/runbook.robot) |      Create an alert in Opsgenie. |
| ping-host-availability | SLI | [sli.robot](./codebundles/ping-host-availability/sli.robot) |      Ping a host and retrieve packet loss percentage. |
| pingdom-health | SLI | [sli.robot](./codebundles/pingdom-health/sli.robot) |      Check health of Pingdom platform. |
| prometheus-queryinstant-transform | SLI | [sli.robot](./codebundles/prometheus-queryinstant-transform/sli.robot) |      Run a PromQL query against Prometheus instant query API, perform a provided transform, and return the result. |
| prometheus-queryrange-transform | SLI | [sli.robot](./codebundles/prometheus-queryrange-transform/sli.robot) |      Run a PromQL query against Prometheus range query API, perform a provided transform, and return the result. |
| remote-http-ok | SLI | [sli.robot](./codebundles/remote-http-ok/sli.robot) |      Check that a HTTP endpoint is healthy and returns in a target latency. |
| rest-basicauth | SLI | [sli.robot](./codebundles/rest-basicauth/sli.robot) |      A general purpose REST SLI for querying and extracting data from a REST endpoint that uses a basic auth flow. |
| rest-explicitoauth2-basicauth | SLI | [sli.robot](./codebundles/rest-explicitoauth2-basicauth/sli.robot) |      A REST SLI for querying and extracting data from a REST endpoint that needs an explicit oauth2 flow. |
| rest-explicitoauth2-tokenheader | SLI | [sli.robot](./codebundles/rest-explicitoauth2-tokenheader/sli.robot) |      A REST SLI for querying and extracting data from a REST endpoint that needs an explicit oauth2 flow. |
| rest-generic | SLI | [sli.robot](./codebundles/rest-generic/sli.robot) |      A general purpose REST SLI for querying and extracting data from a REST endpoint that uses a implicit oauth2 flow. |
| rocketchat-plain-notification | TaskSet | [runbook.robot](./codebundles/rocketchat-plain-notification/runbook.robot) |      Send a message to an RocketChat channel. |
| sysdig-monitor-metric | SLI | [sli.robot](./codebundles/sysdig-monitor-metric/sli.robot) |      Queries the Sysdig data API to fetch metric data. |
| sysdig-monitor-promqlmetric | SLI | [sli.robot](./codebundles/sysdig-monitor-promqlmetric/sli.robot) |      Queries the Sysdig data API with a PromQL query to fetch metric data. |
| twitter-query-tweets | TaskSet | [runbook.robot](./codebundles/twitter-query-tweets/runbook.robot) |      Queries Twitter to fetch tweets within a specified time range for a specific user handle add them to a report. |
| twitter-query-tweets | SLI | [sli.robot](./codebundles/twitter-query-tweets/sli.robot) |      Queries Twitter to count amount of tweets within a specified time range for a specific user handle. |
| uptimecom-component-ok | SLI | [sli.robot](./codebundles/uptimecom-component-ok/sli.robot) |      Check the status of an Uptime.com component for a given site. |
| vault-ok | SLI | [sli.robot](./codebundles/vault-ok/sli.robot) |      Check the health of a Vault server. |
| web-triage | TaskSet | [runbook.robot](./codebundles/web-triage/runbook.robot) |      Troubleshoot and triage a URL to inspect it for common issues such as an expired certification, missing DNS records, etc. |
