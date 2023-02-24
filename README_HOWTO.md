# General Guidelines for Readmes
The main README.md in this repo is automatically updated by: 
- adding the readme_header.md
- generating an index of the codebundles, their documentation, and use cases

## How Indexing Works
- Codebundles are indexed based on their folder path (under the `codebundles` folder) and the presence of an  sli|slo|runbook.robot file.
- The first line of the .robot `Documentation` line will be added to the table. 
- If a README.md exists in the folder, any `Use Cases` that have a heading that matches `Use Case: SLI` or `Use Case: TaskSet` are also added to the `Documentation` column


## Format of a Codebundle Readme

The ideal format of a README.md codebundle is as follows: 
```
# [Target Platform, Product & Use - e.g. Kubernetes Cortext Metrix Ingester Health ]

## SLI
General description of how the SLI works. e,g, What does it do, how does it calculate the metric, how can it be configured. 

## TaskSet
General description of how the TaskSet works. e,g, What does it do, what is the output, how can it be configured. 


## Use Cases
General use case details can be written here. Often these are not targeting specific use cases or configurations, but provide ideas to readers on how the codebundle might be used. 

### Use Case: SLI: [Use Case Title - Target System or Configuration]
General description of how the codebundle can be used to achieve a specific result. Sometimes is is applicable when using a generic codebundle that is applied to a specific product or system. 

### Use Case: TaskSet: [Use Case Title - Target System or Configuration]
General description of how the codebundle can be used to achieve a specific result. Sometimes is is applicable when using a generic codebundle that is applied to a specific product or system. 

## Requirements
Bullet list of requirements that might include rbac, service account, or configuration details. 

## TODO
General list of todos that you are thinking might ehnance the codebundle or its overall usage. 
- [ ] Add additional documentation
- [ ] Add additional taskset checks 

```
