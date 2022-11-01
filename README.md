![RunWhen](docs/GitHub_Banner.jpg)

# rw-public-codecollection

This directory is intended as a precursor to our first stand-alone public (open source) codecollection repository.


## Codebundle Index
| Folder Name | Type | Path | Documentation |
|---|---|---|---|
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
| chat-sendmessage | TaskSet | [runbook.robot](./codebundles/chat-sendmessage/runbook.robot) |      Send messages and reporting to a variety of chat service providers. |
| datadog-system-load | SLI | [sli.robot](./codebundles/datadog-system-load/sli.robot) |      Retrieve a DataDog instance's "System Load" metric |
| discord-send-message | TaskSet | [runbook.robot](./codebundles/discord-send-message/runbook.robot) |      Send a message to a Discord channel. |
| dns-latency | SLI | [sli.robot](./codebundles/dns-latency/sli.robot) |      Check DNS latency for Google Resolver. |
| elasticsearch-health | SLI | [sli.robot](./codebundles/elasticsearch-health/sli.robot) |      Check an Elasticsearch cluster's health |
| gcp-opssuite-logquery-dashboard | TaskSet | [runbook.robot](./codebundles/gcp-opssuite-logquery-dashboard/runbook.robot) |      Generate a link to the GCP Log Explorer. |
| gcp-opssuite-logquery | SLI | [sli.robot](./codebundles/gcp-opssuite-logquery/sli.robot) |      Retrieve the number of results of a GCP Log Explorer query. |
| gcp-opssuite-metricquery | SLI | [sli.robot](./codebundles/gcp-opssuite-metricquery/sli.robot) |      Retrieve the result of an MQL query against the GCP Monitoring API. |
| gcp-serviceshealth | SLI | [sli.robot](./codebundles/gcp-serviceshealth/sli.robot) |      Check status of a set of GCP Products for a specific region. |
| github-get-repos-latency | TaskSet | [runbook.robot](./codebundles/github-get-repos-latency/runbook.robot) |      Create a new issue in GitHub Issues. |
| github-get-repos-latency | SLI | [sli.robot](./codebundles/github-get-repos-latency/sli.robot) |      Check GitHub latency by getting a list of repo names. |
| github-status-components | SLI | [sli.robot](./codebundles/github-status-components/sli.robot) |      Check status of the Github platform or a specified set of GitHub services. |
| github-status-incidents | SLI | [sli.robot](./codebundles/github-status-incidents/sli.robot) |      Check for unresolved incidents related to GitHub services, and provides a count of ongoing incidents as a metric. |
| github-status-maintenances | SLI | [sli.robot](./codebundles/github-status-maintenances/sli.robot) |      Retrieve number of upcoming Github platform maintenances over a given window. |
| gitlab-availability | TaskSet | [runbook.robot](./codebundles/gitlab-availability/runbook.robot) |      Troubleshoot issues with GitLab server availability. |
| gitlab-availability | SLI | [sli.robot](./codebundles/gitlab-availability/sli.robot) |      Check availability of a GitLab server. |
| gitlab-get-repos-latency | SLI | [sli.robot](./codebundles/gitlab-get-repos-latency/sli.robot) |      Check GitLab latency by getting a list of repo names. |
| grafana-health | SLI | [sli.robot](./codebundles/grafana-health/sli.robot) |      Check Grafana server health. |
| hello-world | TaskSet | [runbook.robot](./codebundles/hello-world/runbook.robot) |      Basic Hello-World TaskSet |
| http-latency | SLI | [sli.robot](./codebundles/http-latency/sli.robot) |      Measure HTTP latency against a given URL. |
| http-ok | SLI | [sli.robot](./codebundles/http-ok/sli.robot) |      Check if an HTTP request fails or times out of a given latency window. |
| jira-search-issues-latency | TaskSet | [runbook.robot](./codebundles/jira-search-issues-latency/runbook.robot) |      Create an issue in Jira. |
| jira-search-issues-latency | SLI | [sli.robot](./codebundles/jira-search-issues-latency/sli.robot) |      Check Jira latency when searching issues by current user. |
| k8s-kubectl-apiserverhealth | SLI | [sli.robot](./codebundles/k8s-kubectl-apiserverhealth/sli.robot) |      Check the health of a Kubernetes API server using kubectl. |
| k8s-kubectl-run | TaskSet | [runbook.robot](./codebundles/k8s-kubectl-run/runbook.robot) |      Run a kubectl command and retreive the stdout as a report. |
| k8s-kubectl-sanitycheck | TaskSet | [runbook.robot](./codebundles/k8s-kubectl-sanitycheck/runbook.robot) |      Used for troubleshooting the shellservice-based kubectl service |
| k8s-kubectl-top | SLI | [sli.robot](./codebundles/k8s-kubectl-top/sli.robot) |      Retreieve aggregate data via kubectl top command. |
| k8s-triage-statefulset | TaskSet | [runbook.robot](./codebundles/k8s-triage-statefulset/runbook.robot) |      Troubleshoot issues for StatefulSets and their related resources. |
| k8s-troubleshoot-deployment | TaskSet | [runbook.robot](./codebundles/k8s-troubleshoot-deployment/runbook.robot) |      Troubleshooting general issues associated with kubernetes deployment resources. |
| kubectl-query-row-count | SLI | [sli.robot](./codebundles/kubectl-query-row-count/sli.robot) |      Run a kubectl query and retreive number of results as a metric. |
| kubectl-query-value-avg | SLI | [sli.robot](./codebundles/kubectl-query-value-avg/sli.robot) |      Run a kubectl query and return the average of all results for a given field. |
| kubectl-query-value-first | SLI | [sli.robot](./codebundles/kubectl-query-value-first/sli.robot) |      Run a kubectl query and return the first result for a given field. |
| kubectl-query-value-sum | SLI | [sli.robot](./codebundles/kubectl-query-value-sum/sli.robot) |      Run a kubectl query and return the sum of all results for a given field. |
| kubectl-triage | TaskSet | [runbook.robot](./codebundles/kubectl-triage/runbook.robot) |      Triage and troubleshoot a kubernetes namespace |
| msteams-send-message | TaskSet | [runbook.robot](./codebundles/msteams-send-message/runbook.robot) |      Send a message to an MS Teams channel. |
| operations-suite-metric-latency | SLI | [sli.robot](./codebundles/operations-suite-metric-latency/sli.robot) |      Check GCP Operations Suite metric latency. |
| ops-suite-logquery-row-count | SLI | [sli.robot](./codebundles/ops-suite-logquery-row-count/sli.robot) |      DEPRECATED |
| ops-suite-mql-avg-numeric | SLI | [sli.robot](./codebundles/ops-suite-mql-avg-numeric/sli.robot) |      DEPRECATED |
| ops-suite-mql-avg-ram | SLI | [sli.robot](./codebundles/ops-suite-mql-avg-ram/sli.robot) |      DEPRECATED |
| ops-suite-mql-highest-double | SLI | [sli.robot](./codebundles/ops-suite-mql-highest-double/sli.robot) |      DEPRECATED |
| ops-suite-mql-sum-double | SLI | [sli.robot](./codebundles/ops-suite-mql-sum-double/sli.robot) |      DEPRECATED |
| ops-suite-mql-sum-int | SLI | [sli.robot](./codebundles/ops-suite-mql-sum-int/sli.robot) |      DEPRECATED |
| opsgenie-alert | TaskSet | [runbook.robot](./codebundles/opsgenie-alert/runbook.robot) |      Create an alert in Opsgenie. |
| ping-host-availability | SLI | [sli.robot](./codebundles/ping-host-availability/sli.robot) |      Ping a host and retrieve packet loss percentage. |
| pingdom-health | SLI | [sli.robot](./codebundles/pingdom-health/sli.robot) |      Check health of Pingdom platform. |
| prometheus-query-aggregate | SLI | [sli.robot](./codebundles/prometheus-query-aggregate/sli.robot) |      Run a PromQL query against Prometheus and retrieve the aggregate of the result. |
| prometheus-queryinstant-transform | SLI | [sli.robot](./codebundles/prometheus-queryinstant-transform/sli.robot) |      Run a PromQL query against Prometheus instant query API, perform a provided transform, and return the result. |
| prometheus-queryrange-transform | SLI | [sli.robot](./codebundles/prometheus-queryrange-transform/sli.robot) |      Run a PromQL query against Prometheus range query API, perform a provided transform, and return the result. |
| remote-http-ok | SLI | [sli.robot](./codebundles/remote-http-ok/sli.robot) |      Check that a HTTP endpoint is healthy and returns in a target latency. |
| rocketchat-plain-notification | TaskSet | [runbook.robot](./codebundles/rocketchat-plain-notification/runbook.robot) |      Send a message to an RocketChat channel. |
| sysdig-monitor-metric | SLI | [sli.robot](./codebundles/sysdig-monitor-metric/sli.robot) |      Queries the Sysdig data API to fetch metric data. |
| sysdig-monitor-promqlmetric | SLI | [sli.robot](./codebundles/sysdig-monitor-promqlmetric/sli.robot) |      Queries the Sysdig data API with a PromQL query to fetch metric data. |
| uptimecom-component-ok | SLI | [sli.robot](./codebundles/uptimecom-component-ok/sli.robot) |      Check the status of an Uptime.com component for a given site. |
| vault-ok | SLI | [sli.robot](./codebundles/vault-ok/sli.robot) |      Check the health of a Vault server. |
| web-triage | TaskSet | [runbook.robot](./codebundles/web-triage/runbook.robot) |      Troubleshoot and triage a URL to inspect it for common issues such as an expired certification, missing DNS records, etc. |
