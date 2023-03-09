# Kong Ingress Health Google Managed Prometheus (promql)
This codebundle provides an opinionated healthcheck on ingress objects that are managed by the Kong ingress controller. It requires that the Prometheus plugin is configured appropriatel such that metrics are being sent to Google Managed Prometheus. 


## Service Level Indicator
This SLI queries the Google Managed Prometheus service for Kong related Prometheus metrics that are tied to a single ingress resource. Produces a Score of 1 (healthy) or 0 (unhealthy). Supports values that are between 0 and 1 depending on the result of each test. The suite of checks considered are:
- is the **HTTP error rate** within acceptable levels?
- are there any **upstream errors** reported?
- are **request latencies** within acceptable levels?

Thresholds can be configured for the **HTTP Error rate** or **request latencies** to still be healthy. 

Each of these checks receives a score of 1 (healthy) or 0 (unhealthy), and they are added up and divided by the total number of checks. This means that an ingress object can have a health score between 0 and 1 depending on the types of issues that are occuring. 



## Use Cases
### Use Case: SLI: Kong Ingress Object Health
The following use case provides an example configuration for an ingress object that looks like the following: 
- Example Kubernetes ingress object: 
```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    konghq.com/https-redirect-status-code: "301"
    konghq.com/protocols: https
  name: ob
  namespace: online-boutique
spec:
  ingressClassName: kong
  rules:
  - host: b.demo.here.com
    http:
      paths:
      - backend:
          service:
            name: frontend-external
            port:
              number: 80
        path: /
        pathType: Prefix
  tls:
  - hosts:
    - ob.demo.here.com
    secretName: ob-demo-tls
```

- Example codebundle configuration: 
```
configProvided:
  - name: HTTP_ERROR_CODES
    value: 5.*
  - name: HTTP_ERROR_RATE_WINDOW
    value: 1m
  - name: HTTP_ERROR_RATE_THRESHOLD
    value: '2'
  - name: PROJECT_ID
    value: [gcp-project-id]]
  - name: INGRESS_UPSTREAM
    value: frontend-external.online-boutique.80.svc
  - name: INGRESS_SERVICE
    value: online-boutique.ob.frontend-external.80
  - name: REQUEST_LATENCY_THRESHOLD
    value: '100'
```

With the example above, an ingress would be be considerd a 0 (unhealthy) if: 
- Any http 500 codes are occuring at a rate > that 2/s
- Upstream targets report dns_error or unhealthy status codes
- The 99th percentile of request latencies are > 100ms

## Requirements
### Service Account Requirements  
This codebundle requires a service account and accompanying json key uploaded as a secret to the workspace.

The service account should have the following roles: 
- Logs Viewer - `roles/logging.viewer`
- Monitoring Viewer - `roles/monitoring.viewer`

> Note: It's likely that only the Monitoring Viewer role is required for promql queries, but both roles are helpful when using other gcp-opssuite* codebundles. 

Please see the [documentation for creating service accounts](https://cloud.google.com/iam/docs/creating-managing-service-accounts)

## Helpful Resources
- [https://docs.konghq.com/hub/kong-inc/prometheus/](https://docs.konghq.com/hub/kong-inc/prometheus/)