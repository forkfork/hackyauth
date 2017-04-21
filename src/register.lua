local sql = require('lib/sql')
local hash = require('lib/hash')
local cjson = require('cjson.safe')
local resty_random = require('resty.random')
local str = require('resty.string')
local ck = require('resty.cookie')
local say_err = require('lib/errs')
local authjwt = require('lib/authjwt')

local _M = {}

local create_query = [[
  INSERT INTO user (
    org_name,
    name,
    email,
    password,
    salt,
    details
  ) VALUES (
    %s,
    %s,    
    %s,
    %s,
    %s,
    %s
  );
]]

local check_org = [[
  SELECT
    org.org_name,
    apikey.token
  FROM
    org, apikey
  WHERE
    org.org_name = %s AND
    apikey.token = %s AND
    apikey.org_name = 'admin'
]]

function create(db, org_name, name, email, password)

  local cookie, err = ck:new()
  if not cookie then
    ngx.log(ngx.ERR, err)
    return
  end

  local salt = str.to_hex(resty_random.bytes(16))
  local hashed_pwd = hash(password, salt)

  local err, res = sql.query(db, create_query, org_name, name, email, hashed_pwd, salt, details)
  if err == 1062 then
    say_err('already_registered')
    return
  end

  local token = authjwt.sign(email)
  cookie:set({
    key = "access_token",
    value = token,
    max_age = 60*60*3
  })
  
  return ngx.say(cjson.encode{token=token})
  
end

_M.go = function(db)
  
  local data = ngx.req.get_body_data()
  local org, name, email, password, details
  local params = cjson.decode(data)
  if params then
    org = params.org
    name = params.name
    email = params.email
    password = params.password
    details = params.details or '{}'
    create(db, org, name, email, password, details)
  else
    ngx.say([[{"code":"provide json body with org, name, email, password}"}]])
  end
end

return _M
