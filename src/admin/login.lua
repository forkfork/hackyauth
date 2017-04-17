local sql = require('lib/sql')
local hash = require('lib/hash')
local cjson = require('cjson.safe')

local login_query = [[
  SELECT
    password,
    salt
  FROM
    admin
  WHERE
    email = %s;
]]

local _M = {}

function login_admin(db, email, password)

  local err, res = sql.query(db, login_query, email, password)

  if not res[1] then
    return ngx.say(cjson.encode{code='user_not_found'})
  end

  local salt = res[1].salt
  local db_hashed_pwd = res[1].password
  local hashed_pwd = hash(password, salt)
  if db_hashed_pwd ~= hashed_pwd then
    ngx.say(cjson.encode{code='failed_auth'})
    return 
  end

  return ngx.say(cjson.encode{code='success'})
  
end

_M.go = function(db)
  local data = ngx.req.get_body_data()
  local email, password
  local params = cjson.decode(data)
  if params then
    email = params.email
    password = params.password
  end
  login_admin(db, email, password)
end

return _M
