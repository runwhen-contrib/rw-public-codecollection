# Datadog Metric Query

## SLI
Performs a metric query against the Datadog timeseries API as per the [docs](https://docs.datadoghq.com/api/latest/metrics/#query-timeseries-points) allowing you to feed your datadog metrics into the RunWhen platform.
After fetching the timeseries it extracts data from the point using a json path. Typically this is the newest point in the timeseries.

## Use Cases
### Hook your datadog metrics up to the RunWhen platform
First refer to either a pre-existing dashboard or use the explorer to find timeseries that interest you, eg: https://us3.datadoghq.com/metric/explorer 
> Note:your site may differ based on account location

Then identify the query used to generate the timeseries or that is saved in the dashboard, eg: `max:system.cpu.user{*}`

Provide that query in the configuration for the codebundle in the `METRIC_QUERY` field.

If your query is a traditional timeseries, you likely won't need to change the default `JSON_PATH` of `series[0].pointlist[-1][1]`
You can check the logs output by the codebundle to determine the desired data you'd like to extract, the response blob will be visible there. Eg: given the response:

```
{
 'from_date': 1675977177000,
 'group_by': [],
 'message': '',
 'query': 'max:system.cpu.user{*}',
 'res_type': 'time_series',
 'resp_version': 1,
 'series': [{'aggr': 'max',
             'attributes': {},
             'display_name': 'system.cpu.user',
             'end': 1675977224000,
             'expression': 'max:system.cpu.user{*}',
             'interval': 1,
             'length': 4,
             'metric': 'system.cpu.user',
             'pointlist': [[1675977179000.0, 0.20256583392620087],
                           [1675977194000.0, 0.20229265093803406],
                           [1675977209000.0, 0.26990553736686707],
                           [1675977224000.0, 0.2702702581882477]],
             'query_index': 0,
             'scope': '*',
             'start': 1675977179000,
             'tag_set': [],
             'unit': [{'family': 'percentage',
                       'id': 17,
                       'name': 'percent',
                       'plural': 'percent',
                       'scale_factor': 1.0,
                       'short_name': '%'},
                      None]}],
 'status': 'ok',
 'times': [],
 'to_date': 1675977237000,
 'values': []
}
```

We can access the newest data point using the default json path: `series[0].pointlist[-1][1]`

This is the data point that will be submitted as an SLI metric on the platform.

## Requirements
- A `datadog_api_key` secret in order to authenticate with the API.
- A `datadog_app_key` secret to identify the scope and what application is interacting with the API.
- Which datadog site to connect to, such as `us3.datadoghq.com` or `datadoghq.com` wherever the account resides.

## TODO
- [ ] Add additional documentation