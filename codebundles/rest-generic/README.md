# Rest Standard OAuth2

## SLI
This codebundle is the general-purpose base OAuth2 REST SLI. It should be capable of extracting metric data from the vast majority of REST API endpoints.

In many cases you can use this generic REST codebundle. If you're able to request your data with a curl call then it should directly translate to this codebundle. If you're unable to perform your flow with this codebundle, then for differing workflows see the various `When to use` sections below. For an example of the codebundle in action you can deploy it with the default fields and it will return a metric of 1.

The flow of this codebundle is:
1. Authenticate via implicit OAuth2 with a long-lived access token
2. Receive the response as JSON
3. Use the configured JSON path string to traverse the payload and extract data
4. Push this extracted data as a metric value

In practice with the default values:
- Performs a GET on `https://postman-echo.com/get?mygetparam=1`
- The received data is `"args":{"mygetparam":"1"}`
- Use the JSON path `args.mygetparam` to extract the value `1`
- Push `1` as a metric

## Use Cases
- Extract application-specific data from an endpoint for use as a metric
- Integrate with various REST APIs such as Prometheus
- Translate your curl calls to regular healthchecks by extending this codebundle

### When to use [this](https://docs.runwhen.com/public/v/codebundles/rest-generic) codebundle:
- You're able to authenticate and fetch your data in a single curl call and you'd like to translate it to a codebundle
- your authentication is achieved with a long-lived access token in the header

### When to use [Basic Authentication](https://docs.runwhen.com/public/v/codebundles/rest-basicauth):
- If your REST endpoint is still using the username & password approach for authentication. This codebundle contains fields for setting those secrets.

### When to use [Explicit OAuth2 with Basic Authentication](https://docs.runwhen.com/public/v/codebundles/rest-explicitoauth2-basicauth):
- If your REST endpoint needs an access token in order to request data. This codebundle contains fields for handling those secrets and an adjusted flow.
- and if the authorization endpoint is authenticated with via basic authentication in order to request an access token
- or your bearer token is short-lived and needs to be routinely fetched

### When to use [Explicit OAuth2 with Access token acquisition](https://docs.runwhen.com/public/v/codebundles/rest-explicitoauth2-tokenheader):
- If your REST endpoint needs an access token in order to request data. This codebundle contains fields for handling those secrets and an adjusted flow.
- and if the authorization endpoint is authenticated with using a bearer token in order to request an access token
- or your bearer token is short-lived and needs to be routinely fetched

## Requirements
### For this codebundle:
- `URL` the HTTP url to perform a request against
- `JSON_PATH` which is the json path string used to extract data. Explore https://jmespath.org/ for examples.
- If you require authentication against the HTTP endpoint, Provide a JSON string in the `HEADER` field describing your headers.
eg: `{"Content-Type":"application/json", "my-header":"my-value", "Authorization":"Bearer mytoken"}`
### For basic auth:
- `USERNAME` the username credential used to login for access
- `PASSWORD` the password credential used when logging in for access
### For OAuth2 With Basic Auth:
- `AUTH_URL` the URL of the authorization endpoint used to request the token
- `AUTH_TOKEN_JSON_PATH` the json path used to extract the token string from the authorization response
> Plus username and password
### For OAuth2 With Token:
- `BEARER_TOKEN` is the long-lived token used to request an access token from the authorization endpoint
> Plus the authorization endpoint fields from the oauth2 basic auth section


## TODO
- [ ] Add more use cases
- [ ] Implement a smart variant
