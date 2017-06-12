local sql = require('lib/sql')
local tokens = require('lib/token')
local say_err = require('lib/errs')
local authjwt = require('lib/authjwt')
local cjson = require('cjson.safe')

local validate_query = [[
  SELECT
    name,
    email,
    info
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
  if err then
    ngx.log(ngx.ERR, "Error at SQL validate_query: " .. tostring(err))
  end
  if not res[1] then
    return say_err('not_found')
  end

  local info_obj = cjson.decode(res[1].info) or {}

  return ngx.say(cjson.encode{
    name = res[1].name,
    email = res[1].email,
    info = info_obj})
end

_M.go = function(db, red)
  --local ok, parsed_token = authjwt.validate_cookie()
  local user_id, email, org_name, info = tokens.validate(red)
  ngx.say(cjson.encode{
    user_id = user_id,
    email = email,
    org_name = org_name,
    info = info
  })
end

return _M
