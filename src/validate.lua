local sql = require('lib/sql')
local say_err = require('lib/errs')
local hash = require('lib/hash')
local authjwt = require('lib/authjwt')
local cjson = require('cjson.safe')
local ck = require('resty.cookie')

local validate_query = [[
  SELECT
    detail
  FROM
    user
  WHERE
    user_id = %s and
    org_name = %s;
]]

local _M = {}

local validate = function(db, user_id, org_name)

  local err, res = sql.query(db, validate_query, 
    assert(user_id, "user_id"),
    assert(org_name, "org_name"))
  if not res[1] then
    return say_err('not_found')
  end

  return ngx.say(cjson.encode{detail=res[1].detail})
end

_M.go = function(db)
  local token, parsed_token, field
  local cookie = ck:new()

  field = cookie:get("access_token")
  if not field then
    return say_err('failed_auth')
  end
  local verified, parsed_token = authjwt.validate(field)

  validate(db, parsed_token.sub, parsed_token.iid)
end

return _M
