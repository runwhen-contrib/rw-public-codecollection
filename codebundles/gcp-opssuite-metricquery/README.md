# GCP Operations Suite Metric Query 


## SLI
Performs a metric query using a Google MQL statement on the Ops Suite API

## Use Cases

### Use Case: SLI: QCP Exceeded Quotas
If quotas are being exeeced, you might be experienceing issues with providsioning new services. Use this code bundle with the following configuration to identify if any quotas are exceeded in the GCP project. 

- MQL Statement: 
```fetch consumer_quota | metric 'serviceruntime.googleapis.com/quota/exceeded' | group_by 10m, [value_exceeded_count_true: count_true(value.exceeded)] | every 10m | group_by [],[value_exceeded_count_true_aggregate: aggregate(value_exceeded_count_true)]```
- No Result Overwite: `True`
- No Result Value: `0`

With this query, it's a *good* sign when no data is returned, meaning that no quotas have been exceeded. With that said, you must set to the no `result overwrite` and `no result values` so that the codebundle doesn't error out when no data is returned. 

## Requirements

## TODO
- [ ] Add additional documentation