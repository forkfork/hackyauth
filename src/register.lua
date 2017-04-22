local sql = require('lib/sql')
local hash = require('lib/hash')
local cjson = require('cjson.safe')
local resty_random = require('resty.random')
local str = require('resty.string')
local ck = require('resty.cookie')
local uuid = require('lib/uuid')
local say_err = require('lib/errs')
local authjwt = require('lib/authjwt')

local _M = {}

local create_query = [[
  INSERT INTO user (
    user_id,
    org_name,
    name,
    email,
    password,
    salt,
    detail
  ) VALUES (
    %s,
    %s,
    %s,    
    %s,
    %s,
    %s,
    %s
  );
]]

local function create(db, org_name, name, email, password, detail)

  local cookie, err = ck:new()
  if not cookie then
    ngx.log(ngx.ERR, err)
    return
  end

  local salt = str.to_hex(resty_random.bytes(16))
  local hashed_pwd = hash(password, salt)
  local user_id = uuid()

  local err, res = sql.query(db, create_query, 
    assert(user_id, "user_id"),
    assert(org_name, "org_name"),
    assert(name, "name"),
    assert(email, "email"),
    assert(hashed_pwd, "hashed_pwd"), 
    assert(salt, "salt"),
    assert(detail, "detail"))
  if err == 1062 then
    say_err('already_registered')
    return
  end

  local token = authjwt.sign(user_id, org_name)
  cookie:set({
    key = "access_token",
    value = token,
    max_age = 60*60*3
  })
  
  return ngx.say(cjson.encode{token=token})
  
end

_M.go = function(db)
  
  local data = ngx.req.get_body_data()
  local org, name, email, password, detail
  local params = cjson.decode(data)
  if params then
    org = params.org
    name = params.name
    email = params.email
    password = params.password
    detail = params.detail or '{}'
    ngx.log(ngx.ERR, "detail is " .. tostring(detail))
    create(db, org, name, email, password, detail)
  else
    ngx.say([[{"code":"provide json body with org, name, email, password}"}]])
  end
end

return _M
