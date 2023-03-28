# Run Generic Gcloud Commands
These two codebundle can be used to run arbitrary gcloud commands to perform automated tasks, capture output for a report, or return a metric for surfacing in an SLI.

> Note: the `gcloud auth activate-service-account` call is done for you implicitly, so there's no need to add it into your command string.

## SLI 
A gcloud SLI for querying and extracting data from a generic gcloud call. Uses the hosted gcloud service, supports jq for parsing, and should prodice a single metric.

## TaskSet
Run a gcloud cli command and capture its output for use in a report, such as logs, restarting a VM, etc.

## Use Cases
### SLI: Get Number of Error Logs
This example uses the SLI fetches the up to 20 warning/error log entries in the last 15 minutes as json, before counting the number of entries and providing it as a metric for your SLI. 

```
GCLOUD_COMMAND='gcloud logging read "severity>=WARNING" --freshness=15m --limit=20 --format=json | jq length'
```

### TaskSet: Fetch Last 5 Errors and Present in Report
This example uses the TaskSet variant of the codebundle to fetch stdout and place it into a report on the platform for display to to users. In this case we're adding the last 5 warning/error log entries to a report (the entries will default to yaml)

```
GCLOUD_COMMAND='gcloud logging read "severity>=WARNING" --freshness=15m --limit=5'
```

## Requirements
- The gcloud command string you'd like to run
- A service account credentials json file to be used for authentication

## TODO
- [ ] Expand on examples
- [ ] Determine if/what other gcloud plugins need to be installed for complex use cases