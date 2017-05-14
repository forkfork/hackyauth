local resty_random = require('resty.random')
local cjson = require('cjson.safe')
local str = require('resty.string')
local sql = require('lib/sql')
local hash = require('lib/hash')
local authjwt = require('lib/authjwt')
local ck = require('resty/cookie')

local _M = {}

local check_token = [[
  SELECT
    email,
    org_name
  FROM
    password_reset
  WHERE
    token = %s AND
    expiry > current_timestamp;
]]

local use_token = [[
  UPDATE
    user
  SET
    password = %s,
    salt = %s
  WHERE
    email = %s AND
    org_name = %s;

  UPDATE
    password_reset
  SET
    status = 'used'
  WHERE
    token = %s;
]]
local reset_password = function(db, token, password)
  local err, res, _
  err, res = sql.query(db, check_token,
    assert(token, "token"))
  if err then
    ngx.log(ngx.ERR, "error running sql check_token: " .. tostring(err))
  end
  if #res ~= 1 then
    ngx.status = 401
    ngx.say("token not valid")
    return
  end

  local email, org_name = res[1].email, res[1].org_name
  local salt = str.to_hex(resty_random.bytes(16))
  local hashed_pwd = hash(password, salt)

  err, _ = sql.query(db, use_token,
    assert(hashed_pwd, "hashed_pwd"),
    assert(salt, "salt"),
    assert(email, "email"),
    assert(org_name, "org_name"),
    assert(token, "token"))
  if err then
    ngx.log(ngx.ERR, "error running sql use_token: " .. tostring(err))
  end

  ngx.say("updated")

end

_M.go = function(db)
  local data = ngx.req.get_body_data()
  local params = cjson.decode(data)
  if params then
    reset_password(db, params.token, params.password)
  else
    ngx.say([[{"code":"provide json body with org, email}"}]])
  end
end

return _M
