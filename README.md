# kong-jwt-claim-headers

Add unencrypted, base64-decoded claims from a JWT payload as request headers to
the upstream service.

## Installation

```bash
luarocks install kong-jwt-claim-headers
```

## How it works

When enabled, this plugin will add new headers to requests based on the claims 
in the JWT provided in the request. The mappings from claim keys to request headers are defined in `claim_headers.lua`.

For example, if the JWT payload object is

```json
{
  "uid" : "123456",
  "sub" : "johndoe@gmail.com",
  "aud" : "affiliate",
  "aid" : "323232",
  "pid" : "987654"
}
```

and the mappings in `claim_headers.lua` are

```lua
return {
  ["uid"] = "X-Consumer-Token-User-Id",
  ["sub"] = "X-Consumer-Token-User-Email",
  ["aud"] = "X-Consumer-Token-Scopes"
}
```

then the following headers would be added.

```
X-Consumer-Token-User-Id : "123456"
X-Consumer-Token-User-Email : "johndoe@gmail.com"
X-Consumer-Token-Scopes : "affiliate"
```

## Configuration

Similar to the built-in JWT Kong plugin, you can associate the jwt-claim-headers
plugin with an API with the following request:

```bash
curl -X POST http://localhost:8001/apis/29414666-6b91-430a-9ff0-50d691b03a45/plugins \
  --data "name=jwt-claim-headers" \
  --data "config.uri_param_names=jwt"
```

form parameter|required|description
---|---|---
`name`|*required*|The name of the plugin to use, in this case: `jwt-claim-headers`
`uri_param_names`|*optional*|A list of querystring parameters that Kong will inspect to retrieve JWTs. Defaults to `jwt`.

## Acknowledgements

Inspired by [kong-plugin-jwt-claims-headers](https://github.com/wshirey/kong-plugin-jwt-claims-headers), thanks **wshirey**!
