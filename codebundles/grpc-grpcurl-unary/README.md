# gRPC Unary
A generic gRPC codebundle that uses the the grpcurl service to send requests to gRPC services. The user can paste in their favorite grpcurl shell commands and fetch data with them.
Supports jq for processing output and expects to output in json format. 

## SLI 
A grpcurl SLI for querying and extracting data from a generic grpcurl call. Uses the hosted grpcurl service, supports jq for parsing, and should produce a single metric.

## TaskSet
A gprcurl TaskSet for querying and extracting data from a generic grpcurl call. Uses the hosted grpcurl service, supports jq for parsing, will typically output in json.

## Use Cases
### SLI: Use gRPC result as metric
This example uses the SLI to fetch json data from an arbitrary gRPC service and submit a value from the json payload as a metric.

```
GRPCURL_COMMAND="grpcurl -plaintext -d '{"greeting": "1"}' grpc.postman-echo.com:443 HelloService/SayHello | jq '(.reply | split(" "))[1]'"
```
### TaskSet: Show gRPC service proto information
This example uses the TaskSet to show the proto information of a gRPC service.

```
GRPCURL_COMMAND="grpcurl -plaintext grpc.postman-echo.com:443 describe"
```

## Requirements
- The gRPCurl command to run
- A gRPC service with server reflection enabled

## TODO
- [ ] Support proto file uploads
- [ ] Add support for other streaming methods
- [ ] Add additional report formatting so that it's not just json