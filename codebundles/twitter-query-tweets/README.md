# Twitter Query Tweers

## SLI
Queries Twitter to count amount of tweets within a specified time range for a specific user handle.

## TaskSet
Queries Twitter to fetch tweets within a specified time range for a specific user handle add them to a report.


## Use Cases
### SLI & TaskSet: Count and fetch tweets within the last day
In our use case, the twitter handle [gitbookstatus](https://twitter.com/gitbookstatus) uses twitter to post updates about their service. The SLI can be configured to fetch and count any tweets within the last day, and the Runbook can be configured in the same way, but delivering the tweet content.

Example configuration parameters for both the SLI and TaskSet: 
```
Handle: gitbookstatus
Max Tweets: 5
Max Tweet Age: 1
Min Tweet Age: 0
```


## Requirements

## TODO
- [ ] Add additional documentation
more test  test test test test test test test test test test