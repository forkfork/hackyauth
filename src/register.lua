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

local check_org_query = [[
  SELECT
    region
  FROM
    org
  WHERE
    name = %s AND
    status = 'active';
]]

local create_query = [[
  INSERT INTO user (
    user_id,
    org_name,
    name,
    email,
    password,
    salt,
    pub_info,
    priv_info
  ) VALUES (
    %s,
    %s,
    %s,    
    %s,
    %s,
    %s,
    %s,
    %s
  );
]]

local function create(db, org_name, name, email, password, pub_info, priv_info)

  local cookie, err = ck:new()

  local salt = str.to_hex(resty_random.bytes(16))
  local hashed_pwd = hash(password, salt)
  local user_id = uuid()

  local err, res = sql.query(db, check_org_query,
    assert(org_name, "org_name"))

  if err or #res < 1 then
    return say_err('bad_input')
  end

  err, res = sql.query(db, create_query, 
    assert(user_id, "user_id"),
    assert(org_name, "org_name"),
    assert(name, "name"),
    assert(email, "email"),
    assert(hashed_pwd, "hashed_pwd"), 
    assert(salt, "salt"),
    assert(pub_info, "pub_info"),
    assert(priv_info, "priv_info"))
  if err == 1062 then
    return say_err('already_registered')
  end

  local token = authjwt.sign(user_id, org_name, cjson.decode(pub_info))
  cookie:set({
    key = "access_token",
    value = token,
    max_age = 60*60*3
  })
  
  return ngx.say(cjson.encode{token=token})
  
end

_M.go = function(db)
  
  local data = ngx.req.get_body_data()
  local org, name, email, password
  local pub_info = '{}'
  local priv_info = '{}'
  local params = cjson.decode(data)
  if params then
    org = params.org
    name = params.name
    email = params.email
    password = params.password
    if params.pub_info then
      pub_info = cjson.encode(params.pub_info)
      if not pub_info then
        return ngx_err('bad_input')
      end
    end
    if params.priv_info then
      priv_info = cjson.encode(params.priv_info)
      if not priv_info then
        return ngx_err('bad_input')
      end
    end
    create(db, org, name, email, password, pub_info, priv_info)
  else
    ngx.say([[{"code":"provide json body with org, name, email, password}"}]])
  end
end

return _M
