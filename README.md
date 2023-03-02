![](docs/GitHub_Banner.jpg)

# RunWhen Public Codecollection
This repository is the primary public codecollection that is to be used within the RunWhen platform. It contains codebundles that can be used in SLIs, SLOs, and TaskSets. 

Please see the **[contributing](CONTRIBUTING.md)** and **[code of conduct](CODE_OF_CONDUCT.md)** for details on adding your contributions to this project. 

Documentation for each codebundle is maintained in the README.md alongside the robot code and is published at [https://docs.runwhen.com/public/v/codebundles/](https://docs.runwhen.com/public/v/codebundles/). Please see the [readme howto](README_HOWTO.md for details on crafting a codebundle readme that can be indexed. 


## Codebundle Index
| Folder Name | Type | Path | Documentation | 
|---|---|---|---|
| [argocd-healthcheck](./codebundles/argocd-healthcheck/) | SLI | [sli.robot](./codebundles/argocd-healthcheck/sli.robot) |      Check the health of ArgoCD platfrom by checking the availability of its underlying Deployments and StatefulSets.<br> |
| [artifactory-ok](./codebundles/artifactory-ok/) | SLI | [sli.robot](./codebundles/artifactory-ok/sli.robot) |      Checks an Artifactory instance health endpoint to determine its operational status.<br> |
| [aws-account-limit](./codebundles/aws-account-limit/) | TaskSet | [runbook.robot](./codebundles/aws-account-limit/runbook.robot) |      Retrieve all recently created AWS accounts.<br> | 
| [aws-account-limit](./codebundles/aws-account-limit/) | SLI | [sli.robot](./codebundles/aws-account-limit/sli.robot) |      Retrieve the count of all AWS accounts in an organization.<br> |
| [aws-billing-costsacrosstags](./codebundles/aws-billing-costsacrosstags/) | TaskSet | [runbook.robot](./codebundles/aws-billing-costsacrosstags/runbook.robot) |      Creates a report of AWS line item costs filtered to a list of tagged resources<br> | 
| [aws-billing-tagcosts](./codebundles/aws-billing-tagcosts/) | SLI | [sli.robot](./codebundles/aws-billing-tagcosts/sli.robot) |      Monitors AWS cost and usage data for the latest billing period.<br> |
| [aws-cloudformation-stackevents-count](./codebundles/aws-cloudformation-stackevents-count/) | SLI | [sli.robot](./codebundles/aws-cloudformation-stackevents-count/sli.robot) |      Retrieve the number of detected AWS CloudFormation stack events over a given history<br> |
| [aws-cloudformation-triage](./codebundles/aws-cloudformation-triage/) | TaskSet | [runbook.robot](./codebundles/aws-cloudformation-triage/runbook.robot) |      Triage and troubleshoot various issues with AWS CloudFormation<br> | 
| [aws-cloudwatch-logquery-rowcount-zeroerror](./codebundles/aws-cloudwatch-logquery-rowcount-zeroerror/) | SLI | [sli.robot](./codebundles/aws-cloudwatch-logquery-rowcount-zeroerror/sli.robot) |      Retrieve binary result from an AWS CloudWatch Insights query.<br> |
| [aws-cloudwatch-logquery](./codebundles/aws-cloudwatch-logquery/) | SLI | [sli.robot](./codebundles/aws-cloudwatch-logquery/sli.robot) |      Retrieve number of results from an AWS CloudWatch Insights query.<br> |
| [aws-cloudwatch-metricquery-dashboard](./codebundles/aws-cloudwatch-metricquery-dashboard/) | TaskSet | [runbook.robot](./codebundles/aws-cloudwatch-metricquery-dashboard/runbook.robot) |      Creates a URL to a AWS CloudWatch metrics dashboard with a running query.<br> | 
| [aws-cloudwatch-metricquery](./codebundles/aws-cloudwatch-metricquery/) | SLI | [sli.robot](./codebundles/aws-cloudwatch-metricquery/sli.robot) |      Retrieve the result of an AWS CloudWatch Metrics Insights query.<br> |
| [aws-cloudwatch-tagmetricquery](./codebundles/aws-cloudwatch-tagmetricquery/) | SLI | [sli.robot](./codebundles/aws-cloudwatch-tagmetricquery/sli.robot) |      Retrieve aggregate results from multiple AWS Cloudwatch Metrics Insights queries ran against tagged resources.<br> |
| [aws-ec2-securitycheck](./codebundles/aws-ec2-securitycheck/) | TaskSet | [runbook.robot](./codebundles/aws-ec2-securitycheck/runbook.robot) |      Performs a suite of security checks against a set of AWS EC2 instances.<br> | 
| [aws-s3-stalecheck](./codebundles/aws-s3-stalecheck/) | TaskSet | [runbook.robot](./codebundles/aws-s3-stalecheck/runbook.robot) |      Identify stale AWS S3 buckets, based on last modified object timestamp.<br> | 
| [aws-vm-triage](./codebundles/aws-vm-triage/) | TaskSet | [runbook.robot](./codebundles/aws-vm-triage/runbook.robot) |      Triage and troubleshoot performance and usage of an AWS EC2 instance<br> | 
| [cert-manager-expirations](./codebundles/cert-manager-expirations/) | SLI | [sli.robot](./codebundles/cert-manager-expirations/sli.robot) |      Retrieve number of expired TLS certificates managed by cert-manager within a given window.<br> |
| [cert-manager-healthcheck](./codebundles/cert-manager-healthcheck/) | SLI | [sli.robot](./codebundles/cert-manager-healthcheck/sli.robot) |      Check the health of pods deployed by cert-manager.<br> |
| [curl-generic](./codebundles/curl-generic/) | TaskSet | [runbook.robot](./codebundles/curl-generic/runbook.robot) |      A curl TaskSet for querying and extracting data from a generic curl call. Supports jq. Adds results to the report.<br> | 
| [curl-generic](./codebundles/curl-generic/) | SLI | [sli.robot](./codebundles/curl-generic/sli.robot) |      A curl SLI for querying and extracting data from a generic curl call. Supports jq. Should prodice a single metric.<br> |
| [datadog-metricquery](./codebundles/datadog-metricquery/) | SLI | [sli.robot](./codebundles/datadog-metricquery/sli.robot) |      Fetch the results of a datadog metric timeseries and push the extracted value as an SLI metric.<br> |
| [datadog-system-load](./codebundles/datadog-system-load/) | SLI | [sli.robot](./codebundles/datadog-system-load/sli.robot) |      Retrieve a DataDog instance's "System Load" metric<br> |
| [discord-sendmessage](./codebundles/discord-sendmessage/) | TaskSet | [runbook.robot](./codebundles/discord-sendmessage/runbook.robot) |      Sends a static Discord message via webhook. Contains optional configuration for including runsession info.<br> | 
| [dns-latency](./codebundles/dns-latency/) | SLI | [sli.robot](./codebundles/dns-latency/sli.robot) |      Check DNS latency for Google Resolver.<br> |
| [elasticsearch-health](./codebundles/elasticsearch-health/) | SLI | [sli.robot](./codebundles/elasticsearch-health/sli.robot) |    Check Elasticsearch cluster health<br> |
| [gcp-opssuite-logquery-dashboard](./codebundles/gcp-opssuite-logquery-dashboard/) | TaskSet | [runbook.robot](./codebundles/gcp-opssuite-logquery-dashboard/runbook.robot) |      Generate a link to the GCP Log Explorer.<br> | 
| [gcp-opssuite-logquery](./codebundles/gcp-opssuite-logquery/) | SLI | [sli.robot](./codebundles/gcp-opssuite-logquery/sli.robot) |      Retrieve the number of results of a GCP Log Explorer query.<br> |
| [gcp-opssuite-metricquery](./codebundles/gcp-opssuite-metricquery/) | SLI | [sli.robot](./codebundles/gcp-opssuite-metricquery/sli.robot) |      Performs a metric query using a Google MQL statement on the Ops Suite API<br>**Use Case**: QCP Exceeded Quotas<br> |
| [gcp-opssuite-promql](./codebundles/gcp-opssuite-promql/) | SLI | [sli.robot](./codebundles/gcp-opssuite-promql/sli.robot) |      Performs a metric query using a PromQL statement on the Ops Suite API<br>**Use Case**: Query Prometheus for Kubernetes Deployment Health in a Namespace<br> **Use Case**: Monitoring Crossplane Managed Resource Health with Kube State Metrics<br> |
| [gcp-serviceshealth](./codebundles/gcp-serviceshealth/) | SLI | [sli.robot](./codebundles/gcp-serviceshealth/sli.robot) |      This codebundle sets up a monitor for a specific region and GCP Product, which is then periodically checked for<br>**Use Case**: Monitor for GCP Incidents with Google Kubernetes Engine & Google Compute Engine in 3 Regions<br> |
| [github-actions-workflowtiming](./codebundles/github-actions-workflowtiming/) | SLI | [sli.robot](./codebundles/github-actions-workflowtiming/sli.robot) |      Monitors the average timing of a github actions workflow file within a repo<br> |
| [github-get-repos-latency](./codebundles/github-get-repos-latency/) | TaskSet | [runbook.robot](./codebundles/github-get-repos-latency/runbook.robot) |      Create a new issue in GitHub Issues.<br> | 
| [github-get-repos-latency](./codebundles/github-get-repos-latency/) | SLI | [sli.robot](./codebundles/github-get-repos-latency/sli.robot) |      Check GitHub latency by getting a list of repo names.<br> |
| [github-status-components](./codebundles/github-status-components/) | SLI | [sli.robot](./codebundles/github-status-components/sli.robot) |      Check status of the GitHub platform (https://www.githubstatus.com/) for a specified set of GitHub service components.<br> |
| [github-status-incidents](./codebundles/github-status-incidents/) | SLI | [sli.robot](./codebundles/github-status-incidents/sli.robot) |      Check for unresolved incidents related to GitHub services, and provides a count of ongoing incidents as a metric.<br> |
| [github-status-maintenances](./codebundles/github-status-maintenances/) | SLI | [sli.robot](./codebundles/github-status-maintenances/sli.robot) |      Retrieve number of upcoming Github platform maintenances over a given window.<br> |
| [gitlab-availability](./codebundles/gitlab-availability/) | TaskSet | [runbook.robot](./codebundles/gitlab-availability/runbook.robot) |      Troubleshoot issues with GitLab server availability.<br> | 
| [gitlab-availability](./codebundles/gitlab-availability/) | SLI | [sli.robot](./codebundles/gitlab-availability/sli.robot) |      Check availability of a GitLab server.<br> |
| [gitlab-get-repos-latency](./codebundles/gitlab-get-repos-latency/) | SLI | [sli.robot](./codebundles/gitlab-get-repos-latency/sli.robot) |      Check GitLab latency by getting a list of repo names.<br> |
| [googlechat-sendmessage](./codebundles/googlechat-sendmessage/) | TaskSet | [runbook.robot](./codebundles/googlechat-sendmessage/runbook.robot) |      Sends a static Google Chat message via webhook. Contains optional configuration for including runsession info.<br> | 
| [grafana-health](./codebundles/grafana-health/) | SLI | [sli.robot](./codebundles/grafana-health/sli.robot) |      Check Grafana server health.<br> |
| [hello-world](./codebundles/hello-world/) | TaskSet | [runbook.robot](./codebundles/hello-world/runbook.robot) |      Basic Hello-World TaskSet<br> | 
| [http-latency](./codebundles/http-latency/) | SLI | [sli.robot](./codebundles/http-latency/sli.robot) |      Measure HTTP latency against a given URL.<br> |
| [http-ok](./codebundles/http-ok/) | SLI | [sli.robot](./codebundles/http-ok/sli.robot) |      Check if an HTTP request against a URL fails or times out of a given latency window.<br> |
| [jira-search-issues-latency](./codebundles/jira-search-issues-latency/) | TaskSet | [runbook.robot](./codebundles/jira-search-issues-latency/runbook.robot) |      Create an issue in Jira.<br> | 
| [jira-search-issues-latency](./codebundles/jira-search-issues-latency/) | SLI | [sli.robot](./codebundles/jira-search-issues-latency/sli.robot) |      Check Jira latency when searching issues by current user.<br> |
| [k8s-cortexmetrics-ingestor-health](./codebundles/k8s-cortexmetrics-ingestor-health/) | TaskSet | [runbook.robot](./codebundles/k8s-cortexmetrics-ingestor-health/runbook.robot) |        Uses kubectl to query the state of a ingestor ring. Returns the json of injester id, status and timestamp.<br> | 
| [k8s-cortexmetrics-ingestor-health](./codebundles/k8s-cortexmetrics-ingestor-health/) | SLI | [sli.robot](./codebundles/k8s-cortexmetrics-ingestor-health/sli.robot) |        Uses kubectl to query the state of a ingestor ring and determine if it's healthy. Returns 1 if healthy, 0 if unhealthy.<br>**Use Case**: Monitoring Grafana Mimir Ingester Health<br> |
| [k8s-daemonset-healthcheck](./codebundles/k8s-daemonset-healthcheck/) | SLI | [sli.robot](./codebundles/k8s-daemonset-healthcheck/sli.robot) |        Checks that the current state of a daemonset is healthy and returns a score of either 1 (healthy) or 0 (unhealthy).<br> |
| [k8s-decommission-workloads](./codebundles/k8s-decommission-workloads/) | TaskSet | [runbook.robot](./codebundles/k8s-decommission-workloads/runbook.robot) |      Searches a namespace for matching objects and provides the commands to decommission them.<br> | 
| [k8s-kubectl-apiserverhealth](./codebundles/k8s-kubectl-apiserverhealth/) | SLI | [sli.robot](./codebundles/k8s-kubectl-apiserverhealth/sli.robot) |      Check the health of a Kubernetes API server using kubectl.<br> |
| [k8s-kubectl-canaryvolumemount](./codebundles/k8s-kubectl-canaryvolumemount/) | SLI | [sli.robot](./codebundles/k8s-kubectl-canaryvolumemount/sli.robot) |        Creates an adhoc one-shot job which mounts a PVC as a canary test, which is polled for success before being torn down.<br> |
| [k8s-kubectl-eventquery](./codebundles/k8s-kubectl-eventquery/) | SLI | [sli.robot](./codebundles/k8s-kubectl-eventquery/sli.robot) |        Returns the number of events with matching messages as an SLI metric.<br> |
| [k8s-kubectl-get](./codebundles/k8s-kubectl-get/) | SLI | [sli.robot](./codebundles/k8s-kubectl-get/sli.robot) |        This codebundle runs a kubectl get command that produces a value and pushes the metric.<br>**Use Case**: Query all Certificates that are **NOT** "Ready" in a namespace<br> **Use Case**: Count unhealthy Crossplane resources<br> **Use Case**: Sum, up all container restarts in a namespace<br> **Use Case**: Count all Flux HelmReleases that are **NOT** "Ready"<br> **Use Case**: Count all Kubernetes API Services<br> **Use Case**: Count all Kubernetes API Services that are **NOT** "Ready"<br> **Use Case**: Count all Services without Endpoints<br> |
| [k8s-kubectl-namespace-healthcheck](./codebundles/k8s-kubectl-namespace-healthcheck/) | TaskSet | [runbook.robot](./codebundles/k8s-kubectl-namespace-healthcheck/runbook.robot) |      This taskset runs general troubleshooting checks against all applicable objects in a namespace, checks error events, and searches pod logs for error entries.<br> | 
| [k8s-kubectl-namespace-healthcheck](./codebundles/k8s-kubectl-namespace-healthcheck/) | SLI | [sli.robot](./codebundles/k8s-kubectl-namespace-healthcheck/sli.robot) |      This SLI uses kubectl to score namespace health. Produces a value between 0 (completely failing thet test) and 1 (fully passing the test). Looks for container restarts, events, and pods not ready.<br> |
| [k8s-kubectl-run](./codebundles/k8s-kubectl-run/) | TaskSet | [runbook.robot](./codebundles/k8s-kubectl-run/runbook.robot) |      This codebundle runs an arbitrary kubectl command and writes the stdout to a report.<br> | 
| [k8s-kubectl-sanitycheck](./codebundles/k8s-kubectl-sanitycheck/) | TaskSet | [runbook.robot](./codebundles/k8s-kubectl-sanitycheck/runbook.robot) |      Used for troubleshooting the shellservice-based kubectl service<br> | 
| [k8s-kubectl-top](./codebundles/k8s-kubectl-top/) | SLI | [sli.robot](./codebundles/k8s-kubectl-top/sli.robot) |      Retreieve aggregate data via kubectl top command.<br> |
| [k8s-patroni-healthcheck](./codebundles/k8s-patroni-healthcheck/) | SLI | [sli.robot](./codebundles/k8s-patroni-healthcheck/sli.robot) |      Uses kubectl (or equivalent) to query the state of a patroni cluster and determine if it's healthy.<br> |
| [k8s-patroni-lag](./codebundles/k8s-patroni-lag/) | TaskSet | [runbook.robot](./codebundles/k8s-patroni-lag/runbook.robot) |      Detects and reinitializes laggy Patroni cluster members which are unable to catchup in replication using kubectl and patronictl.<br> | 
| [k8s-patroni-lag](./codebundles/k8s-patroni-lag/) | SLI | [sli.robot](./codebundles/k8s-patroni-lag/sli.robot) |      Measures the maximum replica lag across a Patroni cluster.<br>**Use Case**: Measure Max Replica Lag In Kubernetes<br> |
| [k8s-postgres-query](./codebundles/k8s-postgres-query/) | TaskSet | [runbook.robot](./codebundles/k8s-postgres-query/runbook.robot) |        Runs a postgres SQL query and pushes the returned result into a report.<br> | 
| [k8s-postgres-query](./codebundles/k8s-postgres-query/) | SLI | [sli.robot](./codebundles/k8s-postgres-query/sli.robot) |        Runs a postgres SQL query and pushes the returned query result as an SLI metric.<br> |
| [k8s-postgres-triage](./codebundles/k8s-postgres-triage/) | TaskSet | [runbook.robot](./codebundles/k8s-postgres-triage/runbook.robot) |        Runs multiple Kubernetes and psql commands to report on the health of a postgres cluster. <br> | 
| [k8s-triage-deploymentreplicas](./codebundles/k8s-triage-deploymentreplicas/) | TaskSet | [runbook.robot](./codebundles/k8s-triage-deploymentreplicas/runbook.robot) |      Triages issues related to a deployment's replicas.<br> | 
| [k8s-triage-patroni](./codebundles/k8s-triage-patroni/) | TaskSet | [runbook.robot](./codebundles/k8s-triage-patroni/runbook.robot) |      Taskset to triage issues related to patroni.<br> | 
| [k8s-triage-statefulset](./codebundles/k8s-triage-statefulset/) | TaskSet | [runbook.robot](./codebundles/k8s-triage-statefulset/runbook.robot) |      A taskset for troubleshooting issues for StatefulSets and their related resources.<br> | 
| [k8s-troubleshoot-deployment](./codebundles/k8s-troubleshoot-deployment/) | TaskSet | [runbook.robot](./codebundles/k8s-troubleshoot-deployment/runbook.robot) |      A taskset for troubleshooting general issues associated with typical kubernetes deployment resources.<br> | 
| [msteams-send-message](./codebundles/msteams-send-message/) | TaskSet | [runbook.robot](./codebundles/msteams-send-message/runbook.robot) |      Send a message to an MS Teams channel.<br> | 
| [opsgenie-alert](./codebundles/opsgenie-alert/) | TaskSet | [runbook.robot](./codebundles/opsgenie-alert/runbook.robot) |      Create an alert in Opsgenie.<br> | 
| [ping-host-availability](./codebundles/ping-host-availability/) | SLI | [sli.robot](./codebundles/ping-host-availability/sli.robot) |      Ping a host and retrieve packet loss percentage.<br> |
| [pingdom-health](./codebundles/pingdom-health/) | SLI | [sli.robot](./codebundles/pingdom-health/sli.robot) |      Check health of Pingdom platform.<br> |
| [prometheus-queryinstant-transform](./codebundles/prometheus-queryinstant-transform/) | SLI | [sli.robot](./codebundles/prometheus-queryinstant-transform/sli.robot) |      Run a PromQL query against Prometheus instant query API, perform a provided transform, and return the result.<br>**Use Case**: Kubernetes Node Heartbeats with Kube State Metrics<br> |
| [prometheus-queryrange-transform](./codebundles/prometheus-queryrange-transform/) | SLI | [sli.robot](./codebundles/prometheus-queryrange-transform/sli.robot) |      Run a PromQL query against Prometheus range query API, perform a provided transform, and return the result.<br> |
| [remote-http-ok](./codebundles/remote-http-ok/) | SLI | [sli.robot](./codebundles/remote-http-ok/sli.robot) |      Check that a HTTP endpoint is healthy and returns in a target latency.<br> |
| [rest-basicauth](./codebundles/rest-basicauth/) | SLI | [sli.robot](./codebundles/rest-basicauth/sli.robot) |      A general purpose REST SLI for querying and extracting data from a REST endpoint that uses a basic auth flow.<br> |
| [rest-explicitoauth2-basicauth](./codebundles/rest-explicitoauth2-basicauth/) | SLI | [sli.robot](./codebundles/rest-explicitoauth2-basicauth/sli.robot) |      A REST SLI for querying and extracting data from a REST endpoint that needs an explicit oauth2 flow.<br> |
| [rest-explicitoauth2-tokenheader](./codebundles/rest-explicitoauth2-tokenheader/) | SLI | [sli.robot](./codebundles/rest-explicitoauth2-tokenheader/sli.robot) |      A REST SLI for querying and extracting data from a REST endpoint that needs an explicit oauth2 flow.<br> |
| [rest-generic](./codebundles/rest-generic/) | SLI | [sli.robot](./codebundles/rest-generic/sli.robot) |      A general purpose REST SLI for querying and extracting data from a REST endpoint that uses a implicit oauth2 flow.<br> |
| [rocketchat-sendmessage](./codebundles/rocketchat-sendmessage/) | TaskSet | [runbook.robot](./codebundles/rocketchat-sendmessage/runbook.robot) |      Sends a static Rocketchat message via webhook. Contains optional configuration for including runsession info.<br> | 
| [slack-sendmessage](./codebundles/slack-sendmessage/) | TaskSet | [runbook.robot](./codebundles/slack-sendmessage/runbook.robot) |      Sends a static Slack message via webhook. Contains optional configuration for including runsession info.<br> | 
| [sysdig-monitor-metric](./codebundles/sysdig-monitor-metric/) | SLI | [sli.robot](./codebundles/sysdig-monitor-metric/sli.robot) |      Queries the Sysdig data API to fetch metric data.<br> |
| [sysdig-monitor-promqlmetric](./codebundles/sysdig-monitor-promqlmetric/) | SLI | [sli.robot](./codebundles/sysdig-monitor-promqlmetric/sli.robot) |      Queries the Sysdig data API with a PromQL query to fetch metric data.<br> |
| [twitter-query-tweets](./codebundles/twitter-query-tweets/) | TaskSet | [runbook.robot](./codebundles/twitter-query-tweets/runbook.robot) |      Queries Twitter to fetch tweets within a specified time range for a specific user handle add them to a report.<br> | 
| [twitter-query-tweets](./codebundles/twitter-query-tweets/) | SLI | [sli.robot](./codebundles/twitter-query-tweets/sli.robot) |      Queries Twitter to count amount of tweets within a specified time range for a specific user handle.<br> |
| [uptimecom-component-ok](./codebundles/uptimecom-component-ok/) | SLI | [sli.robot](./codebundles/uptimecom-component-ok/sli.robot) |      Check the status of an Uptime.com component for a given site.<br> |
| [vault-ok](./codebundles/vault-ok/) | SLI | [sli.robot](./codebundles/vault-ok/sli.robot) |      Check the health of a Vault server.<br> |
| [web-triage](./codebundles/web-triage/) | TaskSet | [runbook.robot](./codebundles/web-triage/runbook.robot) |      Troubleshoot and triage a URL to inspect it for common issues such as an expired certification, missing DNS records, etc.<br> | 
