# CURL Generic
A generic curl codebundle that uses the curl service. Currently does not support auth or additional headers. Have a look at the REST bundles for advanced use cases. 

## SLI 
A curl SLI for querying and extracting data from a generic curl call. Uses the hosted curl service, supports jq for parsing, and should prodice a single metric.

## Use Cases
### SLI: Count the number GitHub Repo Stargazers
This example uses the SLI to collect the list of stargazers on a GitHub repo, uses jq to count them up, and pushes the metric. 

```
CURL_COMMAND="curl --silent -X GET https://api.github.com/repos/runwhen-contrib/rw-public-codecollection/stargazers | jq length"
```

## Requirements

## TODO
- [ ] Add additional documentation