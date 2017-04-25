local sql = require('lib/sql')
local say_err = require('lib/errs')
local hash = require('lib/hash')
local authjwt = require('lib/authjwt')
local cjson = require('cjson.safe')
local ck = require('resty.cookie')

local validate_query = [[
  SELECT
    name,
    email,
    priv_info,
    pub_info
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

  local priv_info_obj = cjson.decode(res[1].priv_info) or {}
  local pub_info_obj = cjson.decode(res[1].pub_info) or {}

  return ngx.say(cjson.encode{
    name = res[1].name,
    email = res[1].email,
    priv_info = priv_info_obj,
    pub_info = pub_info_obj})
end

_M.go = function(db)
  local ok, parsed_token = authjwt.validate_cookie()
  if not ok then
    return say_err('failed_auth')
  end

  validate(db, parsed_token.sub, parsed_token.iid)
end

return _M
