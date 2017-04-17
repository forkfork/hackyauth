local sql = require('lib/sql')
local hash = require('lib/hash')
local cjson = require('cjson.safe')
local resty_random = require('resty.random')
local str = require('resty.string')

local _M = {}

local create_query = [[
  INSERT INTO admin (
    org,
    name,
    email,
    password,
    salt
  ) VALUES (
    %s,
    %s,
    %s,
    %s,
    %s
  );
]]

function create_admin(db, org_name, name, email, password)

  local salt = str.to_hex(resty_random.bytes(16))
  local hashed_pwd = hash(password, salt)

  local err, res = sql.query(db, create_query, org_name, name, email, hashed_pwd, salt)

  ngx.say(cjson.encode(res))
  
end

_M.go = function(db)
  
  local data = ngx.req.get_body_data()
  local org, name, email, password
  local params = cjson.decode(data)
  if params then
    org = params.org
    name = params.name
    email = params.email
    password = params.password
    create_admin(db, org, name, email, password)
  else
    ngx.say([[{"code":"provide json body with org, name, email, password}"}]])
  end
end

return _M
