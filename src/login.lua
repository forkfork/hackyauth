local sql = require('lib/sql')
local tokens = require('lib/token')
local hash = require('lib/hash')
local cjson = require('cjson.safe')
local authjwt = require('lib/authjwt')
local say_err = require('lib/errs')
local ck = require('resty/cookie')

local login_query = [[
  SELECT
    user_id,
    password,
    salt,
    info
  FROM
    user
  WHERE
    email = %s AND
    org_name = %s;
]]

local _M = {}

local login = function(db, red, email, password, org_name)

  local cookie, _ = ck:new()
  local err, res = sql.query(db, login_query, email, org_name)

  if err then
    ngx.log(ngx.ERR, "error in sql login_query: " .. tostring(err))
  end

  if not res[1] then
    return say_err('not_found')
  end
  local row = res[1]

  if row.password ~= hash(password, row.salt) then
    return say_err('failed_auth')
  end

  --local token = authjwt.sign(email, org_name, cjson.decode(row.pub_info))
  ngx.log(ngx.ERR, "creating a token with email: " .. tostring(email))
  local token = tokens.create(red, row.user_id, email, org_name, row.info)
  cookie:set({
    key = "access_token",
    value = token,
    max_age = 60*60*3
  })

  return ngx.say(cjson.encode{token=token})

end

_M.go = function(db, red)
  local data = ngx.req.get_body_data()
  local email, password, org
  local params = cjson.decode(data)
  if params then
    email = params.email
    password = params.password
    org = params.org
    login(db, red, email, password, org)
  end
end

return _M
