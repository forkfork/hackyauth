local jwt = require('resty.jwt')
local certs = require('lib.certs')
local ck = require('resty.cookie')

jwt.set_alg_whitelist({RS256=1,HS256=0})

_M = {}

_M.sign = function(user, org_name, info)
  ngx.update_time()
  local time = ngx.time()
  local exp = time + (60 * 60 * 3) -- 3 hours

  local signed = jwt:sign(certs.private, {
    header = { typ = "JWT", alg = "RS256" },
    payload = {
      iat = time,
      exp = exp,
      sub = user,
      iid = org_name,
      info = info
    }
  })

  return signed
end

local validate = function(token)
  local jwt_obj = jwt:verify(certs.cert, token)

  return jwt_obj.verified, jwt_obj.payload
end

_M.validate = validate

_M.validate_cookie = function()
  local cookie = ck:new()

  local field = cookie:get("access_token")
  if not field then
    return false
  end
  local verified, parsed_token = validate(field)
  if not parsed_token or not verified then
    return false
  end

  return true, parsed_token
end

return _M
