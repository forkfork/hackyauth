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
    email = %s;
]]

local _M = {}

function login(db, email, password)

  local cookie, err = ck:new()
  if not cookie then
    ngx.log(ngx.ERR, err)
    return
  end

  local err, res = sql.query(db, login_query, email, password)

  if not res[1] then
    return say_err('not_found')
  end

  local salt = res[1].salt
  local db_hashed_pwd = res[1].password
  local hashed_pwd = hash(password, salt)
  if db_hashed_pwd ~= hashed_pwd then
    return say_err('failed_auth')
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
  local email, password
  local params = cjson.decode(data)
  if params then
    email = params.email
    password = params.password
    login(db, email, password)
  end
end

return _M
