# Kubernetes Kubectl Event Query

## SLI
This codebundle returns the number of events in a Kubernetes namespace which have messages matching a regex pattern.
Note that this does not sum up the message occurence count, only the Kubernetes object count.

Pattern examples:
- Return results which contain string: `mystring`
- Return results for matches on 1 or 2: `(Search1|Search2)`

## Use Cases
- Measure the number of failed volume mounts occuring by setting the pattern to "FailedMount"

## Requirements
- A kubeconfig with get/list access on event objects in the chosen namespace.
- A chosen `namespace` and `context` to use from the kubeconfig
- A `event pattern` to use for selecting the event objects; refer to extended grep patterns for details on how to write these. run `man grep`.

## TODO
- [ ] Add additional documentation