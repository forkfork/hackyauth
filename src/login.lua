local sql = require('lib/sql')
local hash = require('lib/hash')
local cjson = require('cjson.safe')
local authjwt = require('lib/authjwt')
local say_err = require('lib/errs')
local ck = require('resty/cookie')

local login_query = [[
  SELECT
    password,
    salt
  FROM
    user
  WHERE
    email = %s AND
    org_name = %s;
]]

local _M = {}

local login = function(db, email, password, org_name)

  local cookie, err = ck:new()
  if not cookie then
    ngx.log(ngx.ERR, err)
    return
  end

  local err, res = sql.query(db, login_query, email, org_name)

  if not res[1] then
    return say_err('not_found')
  end

  local salt = res[1].salt
  local db_hashed_pwd = res[1].password
  local hashed_pwd = hash(password, salt)
  if db_hashed_pwd ~= hashed_pwd then
    return say_err('failed_auth')
  end

  local token = authjwt.sign(email, org_name)
  cookie:set({
    key = "access_token",
    value = token,
    max_age = 60*60*3
  })
  
  return ngx.say(cjson.encode{token=token})
  
end

_M.go = function(db)
  local data = ngx.req.get_body_data()
  local email, password, org
  local params = cjson.decode(data)
  if params then
    email = params.email
    password = params.password
    org = params.org
    login(db, email, password, org)
  end
end

return _M
