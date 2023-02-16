# GCP Service Health


## SLI
This codebundle sets up a monitor for a specific region and GCP Product, which is then periodically checked for ongoing incidents based on the history available at https://status.cloud.google.com/incidents.json filtered based on severity level.

## Use Cases
### Use Case: SLI: Monitor for GCP Incidents with Google Kubernetes Engine & Google Compute Engine in 3 Regions
This sample configuration is used to demostrate how to monitor incidents for multiple GCP products in multiple regions within the last 15m: 

```
WITHIN_TIME: 15m
PRODUCTS:  Google Kubernetes Engine,Google Compute Engine
REGIONS: us-central1,us-west2,us-west1
SEVERITY: low
```

## Requirements

## TODO
- [ ] Add additional documentation