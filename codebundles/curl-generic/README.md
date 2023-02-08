# CURL Generic
A generic curl codebundle that uses the curl service. Currently does not support auth or additional headers. Have a look at the REST bundles for advanced use cases. 

## SLI 
A curl SLI for querying and extracting data from a generic curl call. Uses the hosted curl service, supports jq for parsing, and should prodice a single metric.

## TaskSet
A curl TaskSet for querying and extracting data from a generic curl call. Uses the hosted curl service, supports jq for parsing, will output in json.

## Use Cases
### SLI: Count the number GitHub Repo Stargazers
This example uses the SLI to collect the list of stargazers on a GitHub repo, uses jq to count them up, and pushes the metric. 

```
CURL_COMMAND="curl --silent -X GET https://api.github.com/repos/runwhen-contrib/rw-public-codecollection/stargazers | jq length"
```
### SLI: Generate a report of GitHub Repo Stargazers by login-name
This example uses the SLI to collect the list of stargazers on a GitHub repo, uses jq to count them up, and pushes the metric. 

```
CURL_COMMAND="curl -X GET https://api.github.com/repos/runwhen-contrib/rw-public-codecollection/stargazers | jq '.[] | .login'"
```

## Requirements

## TODO
- [ ] Add additional filtering capabilities, SLI math (e.g. avg, sum, count)to mimic k8s-kubectl-get
- [ ] Add additional report formatting so that it's not just json