local authjwt = require('lib/authjwt')
local uuid = require('lib/uuid')
local sql = require('lib/sql')
local tokens = require('lib/token')
local say_err = require('lib/errs')
local cjson = require('cjson')

_M = {}

-- validate jwt
-- ensure org is 'smallauth'
-- insert a token
-- tokens can be used to:
-- * list users (csv)
-- * delete a user
-- * update a user

-- can the special admin user also do those things? maybe

local create_token_query = [[

  INSERT INTO apikey (
    org_name,
    token
  ) VALUES (
    %s,
    %s
  );

]]

local create_token = function(db, org)
  local token = uuid()
  local err, _ = sql.query(db, create_token_query, org, token)
  if err then
    ngx.log(ngx.ERR, "error ")
  end
  ngx.say(cjson.encode{apitoken = token})
end

_M.go = function(db, red)
  local user_id, email, org_name, info = tokens.validate(red)
  ngx.log(ngx.ERR, "got email of " .. tostring(email))
  if org_name ~= 'smallauth' then
    return say_err('failed_auth')
  end
  ngx.log(ngx.ERR, "info is: " .. tostring(info))
  local info_obj = cjson.decode(info)
  assert(info_obj.org, "org")
  create_token(db, info_obj.org)
end

return _M
