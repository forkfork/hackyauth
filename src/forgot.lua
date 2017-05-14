local cjson = require('cjson.safe')
local uuid = require('lib/uuid')
local sql = require('lib/sql')

local email_exists = [[
  SELECT
    email
  FROM
    user
  WHERE
    org_name = %s AND
    email = %s;
]]

local insert_token = [[
  INSERT INTO password_reset (
    org_name, email, token, expiry)
  VALUES (
    %s, %s, %s, current_timestamp + interval 1 hour
  );
]]

local _M = {}

local forgot_password = function(db, org_name, email)
  local err, res, _
  ngx.log(ngx.ERR, "EMAIL IS FORGOTT ^^ " .. tostring(email))
  err, res = sql.query(db, email_exists,
    assert(org_name, "org_name"),
    assert(email, "email"))
  if err then
    ngx.log(ngx.ERR, "Error on sql email_exists: " .. tostring(err))
  end
  if err or #res ~= 1 then
    ngx.status = 404
    ngx.say("account not found")
    return
  end

  local token = uuid(12)

  err, _ = sql.query(db, insert_token,
    assert(org_name, "org_name"),
    assert(email, "email"),
    assert(token, "token"))
  if err then
    ngx.log(ngx.ERR, "Error on sql insert_token: " .. tostring(err))
    return
  end

  ngx.say("sent")

end

_M.go = function(db)
  local data = ngx.req.get_body_data()
  local params = cjson.decode(data)
  if params then
    forgot_password(db, params.org, params.email)
  else
    ngx.say([[{"code":"provide json body with org, email}"}]])
  end
end

return _M
