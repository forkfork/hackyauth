local mysql = require "resty.mysql"
local redis = require "resty.redis"

local adminlanding = require "admin.landing"
local admincss = require "admin.css"
local adminsignup = require "admin.signup"
local admincreatekey = require "admin.create_key"

local login = require "login"
local register = require "register"
local confirm = require "confirm"
local validate = require "validate"

local forgot = require "forgot"
local reset = require "reset"

local route = require "route"

local main = function()

  local red = redis:new()
  red:set_timeout(1000)
  local ok, err, db
  ok, err = red:connect("127.0.0.1", 6379)
  if not ok then
    ngx.say("couldnt init redis")
    return
  end
  db, err = mysql:new()
  if not db then
    ngx.say("couldnt init mysql")
    return
  end


  route(ngx.var.uri, ngx.req.get_method(), {
    '/', 'GET', adminlanding.go,
    '/smallauth.css', 'GET', admincss.go,
    '/login', 'POST', login.go,
    '/register', 'POST', register.go,
    '/confirm', 'POST', confirm.go,
    '/validate', 'GET', validate.go,
    '/forgot', 'POST', forgot.go,
    '/reset', 'POST', reset.go,
    '/signup', 'POST', adminsignup.go,
    '/admin/apikey', 'POST', admincreatekey.go,
  }, db, red)

end

return main
