# rw-public-codecollection

This directory is intended as a precursor to our first stand-alone public (open source) codecollection repository.


## Codebundle Index
| Folder Name | Type | Path | Documentation |
|---|---|---|---|
| artifactory-ok | SLI | [sli.robot](./codebundles/artifactory-ok/sli.robot) |      A codebundle which periodically performs a GET request against a Artifactory URL for health information. |
| aws-account-limit | TaskSet | [runbook.robot](./codebundles/aws-account-limit/runbook/runbook.robot) |    Runbook to get the recently created AWS accounts. |
| aws-account-limit | SLI | [sli.robot](./codebundles/aws-account-limit/sli/sli.robot) |    Get a count of all AWS accounts in the organization. |
| aws-account-limit | SLI | [sli.robot](./codebundles/aws-account-limit/sli/t1_get_roots.robot) |    Get a count of all AWS accounts in the organization. |
| aws-billing-costsacrosstags | TaskSet | [runbook.robot](./codebundles/aws-billing-costsacrosstags/runbook.robot) |      A codebundle which performs a series billing queries using a list of tags to create |
| aws-billing-tagcosts | SLI | [sli.robot](./codebundles/aws-billing-tagcosts/sli.robot) |      A codebundle that can be used to monitor cost and usage data as an SLI for the latest billing period. |
| aws-cloudformation-stackevents-count | SLI | [sli.robot](./codebundles/aws-cloudformation-stackevents-count/sli.robot) |      This codebundle provides an SLI that queries the AWS CloudFormation API |
| aws-cloudformation-triage | TaskSet | [runbook.robot](./codebundles/aws-cloudformation-triage/runbook.robot) |      This codebundle is a set of tasks which can be run to triage and troubleshoot various |
| aws-cloudwatch-logquery-rowcount-zeroerror | SLI | [sli.robot](./codebundles/aws-cloudwatch-logquery-rowcount-zeroerror/sli.robot) |      This codebundle runs an AWS log query against the CloudWatch query insights API |
| aws-cloudwatch-logquery | SLI | [sli.robot](./codebundles/aws-cloudwatch-logquery/sli.robot) |      This codebundle runs an AWS log query against the CloudWatch query insights API |
| aws-cloudwatch-metricquery-dashboard | TaskSet | [runbook.robot](./codebundles/aws-cloudwatch-metricquery-dashboard/runbook.robot) |      When run, this codebundle creates a URL to a CloudWatch metrics dashboard with |
| aws-cloudwatch-metricquery | SLI | [sli.robot](./codebundles/aws-cloudwatch-metricquery/sli.robot) |      This codebundle runs an AWS metric query against the CloudWatch metrics insights API |
| aws-cloudwatch-tagmetricquery | SLI | [sli.robot](./codebundles/aws-cloudwatch-tagmetricquery/sli.robot) |      This codebundle fetches a list of instance IDs filtered by tags, and uses them |
| aws-ec2-securitycheck | TaskSet | [runbook.robot](./codebundles/aws-ec2-securitycheck/runbook.robot) |      This codebundle performs a suite of checks against a set of EC2 instances. |
| aws-s3-stalecheck | TaskSet | [runbook.robot](./codebundles/aws-s3-stalecheck/runbook.robot) |      This codebundle queries all S3 buckets and inspects the last modified timestamp of its objects |
| aws-vm-triage | TaskSet | [runbook.robot](./codebundles/aws-vm-triage/runbook.robot) |  |
| cert-manager-expirations | SLI | [sli.robot](./codebundles/cert-manager-expirations/sli.robot) |      An SLI which queries cert-manager resources to check expiration times of TLS certificates. |
| cert-manager-healthcheck | SLI | [sli.robot](./codebundles/cert-manager-healthcheck/sli.robot) |      An SLI which periodically health checks the pods deployed by cert-manager |
| chat-sendmessage-debug | TaskSet | [runbook.robot](./codebundles/chat-sendmessage-debug/runbook.robot) |  |
| chat-sendmessage | TaskSet | [runbook.robot](./codebundles/chat-sendmessage/runbook.robot) |      This codebundle provides a list of integrations to chat services like Slack or Discord. With it |
| datadog-system-load | SLI | [sli.robot](./codebundles/datadog-system-load/sli/sli.robot) |    Check Datadog system.load metric |
| discord-send-message | TaskSet | [runbook.robot](./codebundles/discord-send-message/runbook/runbook.robot) |    Runbook to send a message to a Discord channel. |
| dns-latency | SLI | [sli.robot](./codebundles/dns-latency/sli/sli.robot) |    SLI to check DNS latency for Google Resolver |
| elasticsearch-health | SLI | [sli.robot](./codebundles/elasticsearch-health/sli/sli.robot) |    Check Elasticsearch cluster health |
| gcp-opssuite-logquery-dashboard | TaskSet | [runbook.robot](./codebundles/gcp-opssuite-logquery-dashboard/runbook.robot) |      A taskset which generates a link to the GCP Log Explorer |
| gcp-opssuite-logquery | SLI | [sli.robot](./codebundles/gcp-opssuite-logquery/sli.robot) |      An SLI which periodically runs the Google Log Query against the Log Explorer Query API |
| gcp-opssuite-metricquery | SLI | [sli.robot](./codebundles/gcp-opssuite-metricquery/sli.robot) |  |
| gcp-serviceshealth | SLI | [sli.robot](./codebundles/gcp-serviceshealth/sli.robot) |      This codebundle sets up a monitor for a specific region and GCP Product, which is then periodically checked for |
| github-get-repos-latency | TaskSet | [runbook.robot](./codebundles/github-get-repos-latency/runbook/runbook.robot) |      Runbook to create a new issue in GitHub Issues. |
| github-get-repos-latency | SLI | [sli.robot](./codebundles/github-get-repos-latency/sli/sli.robot) |      Check GitHub latency by getting a list of repo names. |
| github-status-components | SLI | [sli.robot](./codebundles/github-status-components/sli.robot) |      Check availability of a specified set of GitHub services as provided by https://www.githubstatus.com/, the metric supplied is a |
| github-status-incidents | SLI | [sli.robot](./codebundles/github-status-incidents/sli.robot) |      Check for unresolved incidents related to GitHub services, and provides a count of ongoing incidents as a metric. |
| github-status-maintenances | SLI | [sli.robot](./codebundles/github-status-maintenances/sli.robot) |      This codebundle measures the number of upcoming scheduled GitHub maintenances for the configured time window, and pushes the count as a metric. |
| gitlab-availability | TaskSet | [runbook.robot](./codebundles/gitlab-availability/runbook/runbook.robot) |    Troubleshooting GitLab server availability |
| gitlab-availability | SLI | [sli.robot](./codebundles/gitlab-availability/sli/sli.robot) |    Check availability of the GitLab server |
| gitlab-get-repos-latency | SLI | [sli.robot](./codebundles/gitlab-get-repos-latency/sli/sli.robot) |    Check GitLab latency by getting a list of repo names. |
| grafana-health | SLI | [sli.robot](./codebundles/grafana-health/sli/sli.robot) |    Check Grafana server health |
| hello-world | TaskSet | [runbook.robot](./codebundles/hello-world/runbook.robot) |        A simple-as-possible task set |
| http-latency | SLI | [sli.robot](./codebundles/http-latency/sli.robot) |      This codebundle performs a measurement of golden signal: latency. The returned metric is the number of seconds |
| http-ok-old | SLI | [sli.robot](./codebundles/http-ok-old/sli.robot) |  |
| http-ok | SLI | [sli.robot](./codebundles/http-ok/sli.robot) |      This codebundle performs a measurement of 2 common golden signals: errors & latency, returning a 1 when either |
| jira-search-issues-latency | TaskSet | [runbook.robot](./codebundles/jira-search-issues-latency/runbook/runbook.robot) |    Runbook to create an issue in Jira. |
| jira-search-issues-latency | SLI | [sli.robot](./codebundles/jira-search-issues-latency/sli/sli.robot) |    Check Jira latency when searching issues by current user. |
| k8s-api-health | TaskSet | [runbook.robot](./codebundles/k8s-api-health/runbook/runbook.robot) |    Runbook for troubleshooting. |
| k8s-api-health | SLI | [sli.robot](./codebundles/k8s-api-health/sli/sli.robot) |    Check the K8s Cluster's API health. |
| k8s-delete-pods | TaskSet | [runbook.robot](./codebundles/k8s-delete-pods/runbook/runbook.robot) |    Runbook to check pods which are not in Running state. |
| k8s-kubectl-apiserverhealth | SLI | [sli.robot](./codebundles/k8s-kubectl-apiserverhealth/sli.robot) |      An SLI which polls the Kubernetes API server with kubectl and returns 0 when OK |
| k8s-kubectl-run | TaskSet | [runbook.robot](./codebundles/k8s-kubectl-run/runbook.robot) |      This codebundle runs an arbitrary kubectl command and writes the stdout to a report. |
| k8s-kubectl-sanitycheck | TaskSet | [runbook.robot](./codebundles/k8s-kubectl-sanitycheck/runbook.robot) |      Experimental taskset using the shellservice-based kubectl service |
| k8s-kubectl-top | SLI | [sli.robot](./codebundles/k8s-kubectl-top/sli.robot) |      An SLI which periodically fetches usage data via kubectl top, performs |
| k8s-triage-statefulset | TaskSet | [runbook.robot](./codebundles/k8s-triage-statefulset/runbook.robot) |      A taskset for troubleshooting issues for StatefulSets and their related resources. |
| k8s-troubleshoot-deployment | TaskSet | [runbook.robot](./codebundles/k8s-troubleshoot-deployment/runbook.robot) |      A taskset for troubleshooting general issues associated with typical kubernetes deployment resources. |
| kubectl-query-row-count | SLI | [sli.robot](./codebundles/kubectl-query-row-count/sli.robot) |      An SLI that uses Kubectl to extract data from the Kubernetes API Server |
| kubectl-query-value-avg | SLI | [sli.robot](./codebundles/kubectl-query-value-avg/sli.robot) |  |
| kubectl-query-value-first | SLI | [sli.robot](./codebundles/kubectl-query-value-first/sli.robot) |  |
| kubectl-query-value-sum | SLI | [sli.robot](./codebundles/kubectl-query-value-sum/sli.robot) |  |
| kubectl-raw | SLI | [sli.robot](./codebundles/kubectl-raw/sli.robot) |  |
| kubectl-triage | TaskSet | [runbook.robot](./codebundles/kubectl-triage/runbook.robot) |  |
| msteams-send-message | TaskSet | [runbook.robot](./codebundles/msteams-send-message/runbook/runbook.robot) |    Runbook to send a message to an MS Teams channel. |
| operations-suite-metric-latency | SLI | [sli.robot](./codebundles/operations-suite-metric-latency/sli/sli.robot) |    Check GCP Operations Suite metric latency. |
| ops-suite-logquery-row-count | SLI | [sli.robot](./codebundles/ops-suite-logquery-row-count/sli.robot) |  |
| ops-suite-mql-avg-numeric | SLI | [sli.robot](./codebundles/ops-suite-mql-avg-numeric/sli.robot) |  |
| ops-suite-mql-avg-ram | SLI | [sli.robot](./codebundles/ops-suite-mql-avg-ram/sli.robot) |  |
| ops-suite-mql-highest-double | SLI | [sli.robot](./codebundles/ops-suite-mql-highest-double/sli.robot) |  |
| ops-suite-mql-sum-double | SLI | [sli.robot](./codebundles/ops-suite-mql-sum-double/sli.robot) |      An SLI that performs a GCP MQL statement against the Metrics API, |
| ops-suite-mql-sum-int | SLI | [sli.robot](./codebundles/ops-suite-mql-sum-int/sli.robot) |  |
| opsgenie-alert | TaskSet | [runbook.robot](./codebundles/opsgenie-alert/runbook/runbook.robot) |    Runbook to create an alert in Opsgenie. |
| ping-host-availability | SLI | [sli.robot](./codebundles/ping-host-availability/sli/sli.robot) |    Check availability by pinging host. |
| pingdom-health | SLI | [sli.robot](./codebundles/pingdom-health/sli/sli.robot) |    Check Pingdom health |
| prometheus-query-aggregate | SLI | [sli.robot](./codebundles/prometheus-query-aggregate/sli.robot) |      An SLI that performs a query against a Prometheus' HTTP query API, retrieves the response, |
| prometheus-queryinstant-transform | SLI | [sli.robot](./codebundles/prometheus-queryinstant-transform/sli.robot) |      An SLI that performs a query against a Prometheus' HTTP Instant query API, retrieves the response, |
| prometheus-queryrange-transform | SLI | [sli.robot](./codebundles/prometheus-queryrange-transform/sli.robot) |      An SLI that performs a query against a Prometheus' HTTP Range query API, retrieves the response, |
| remote-http-ok | SLI | [sli.robot](./codebundles/remote-http-ok/sli.robot) |  |
| rocketchat-plain-notification | TaskSet | [runbook.robot](./codebundles/rocketchat-plain-notification/runbook.robot) |  |
| runwhen-papi-healthcheck-ws | SLI | [sli.robot](./codebundles/runwhen-papi-healthcheck-ws/sli.robot) |  |
| simple-slx | SLI | [sli.robot](./codebundles/simple-slx/sli/sli.robot) |    A very simple SLI Robot suite which pushes a static metric to the MetricStore. |
| uptimecom-component-ok | SLI | [sli.robot](./codebundles/uptimecom-component-ok/sli.robot) |      A codebundle used to periodically check the status of a Uptime.com statuspage component. It compares the |
| vault-healh | TaskSet | [runbook.robot](./codebundles/vault-healh/runbook/runbook.robot) |    Runbook for troubleshooting HashiCorp Vault. It collects information |
| vault-healh | SLI | [sli.robot](./codebundles/vault-healh/sli/sli.robot) |    Check HashiCorp Vault health. |
| vault-ok | SLI | [sli.robot](./codebundles/vault-ok/sli.robot) |      A codebundle which periodically performs a GET request against a Vault URL for health information. |
| web-triage | TaskSet | [runbook.robot](./codebundles/web-triage/runbook.robot) |      A codebundle that runs a set of checks against a URL to inspect it for common issues |
