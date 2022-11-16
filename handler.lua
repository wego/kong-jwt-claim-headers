local jwt_decoder = require "kong.plugins.jwt.jwt_parser"
local JWT_PLUGIN_PRIORITY = (require "kong.plugins.jwt.handler").PRIORITY
local CLAIM_HEADERS = require "kong.plugins.jwt-claim-headers.claim_headers"

local kong = kong
local ngx_re_gmatch = ngx.re.gmatch

local JwtClaimHeadersHandler = {
  VERSION = "2.0.0",
  PRIORITY = JWT_PLUGIN_PRIORITY - 100,
}

local function retrieve_token(conf)
  local uri_parameters = kong.request.get_query()

  for _, v in ipairs(conf.uri_param_names) do
    if uri_parameters[v] then
      return uri_parameters[v]
    end
  end

  local authorization_header = kong.request.get_headers()["authorization"]
  if authorization_header then
    local iterator, iter_err = ngx_re_gmatch(authorization_header, "\\s*[Bb]earer\\s+(.+)")
    if not iterator then
      return nil, iter_err
    end

    local m, err = iterator()
    if err then
      return nil, err
    end

    if m and #m > 0 then
      return m[1]
    end
  end
end

function JwtClaimHeadersHandler:access(conf)
  local token, err = retrieve_token(conf)
  if err then
    kong.log.warn("unable to retrieve token: ", err)
    return
  end

  local token_type = type(token)
  if token_type ~= "string" then
    if token_type == "nil" then
      kong.log.warn("missing token")
      return
    else
      kong.log.err("unrecognizable token")
      return
    end
  end

  local jwt, err = jwt_decoder:new(token)
  if err then
    kong.log.err("bad token: ", err)
    return
  end

  local claims = jwt.claims

  for claim_key, claim_value in pairs(claims) do
    local request_header = CLAIM_HEADERS[claim_key]
    if request_header ~= nil then
      kong.service.request.set_header(request_header, claim_value)
    end
  end
end

return JwtClaimHeadersHandler
