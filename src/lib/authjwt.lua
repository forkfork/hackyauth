local jwt = require('resty.jwt')
local certs = require('lib.certs')

_M = {}

_M.sign = function(user)
  ngx.update_time()
  local time = ngx.time()
  local exp = time + (60 * 60 * 3) -- 3 hours

  local signed = jwt:sign(certs.private, {
    header = { typ = "JWT", alg = "RS256" },
    payload = {
      iat = time,
      exp = exp,
      sub = user
    }
  })

  return signed
end

_M.validate = function(token)
  local jwt_obj = jwt:verify(certs.cert, token)

  return jwt_obj.verified, jwt_obj.payload
end

return _M
