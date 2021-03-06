--[[small auth

* Small API. Just do auth, and do it well.
* High uptime guarantee.

Login:

curl -X POST -d '{"username":"harmony","password":"hunter2"}' https://demo.smallauth.com/login

200 { "status": "success", "token": "eaeaeaeaeaeaeae" }
401 { "status": "wrong_password" }

Register:

curl -X POST -d '{"username":"harmony","password":"hunter2"}' https://demo.smallauth.com/register

200 { "status": "success", "token": "eaeaeaeaeaeaeae" }
409 { "status": "user_exists" }

Validate:

curl -X POST -d '{"username":"harmony","password":"hunter2"}' https://demo.smallauth.com/register

200 { "status": "success", "token": "eaeaeaeaeaeaeae" }
409 { "status": "user_exists" }

]]

local fp = io.open("smallauth.html")
local page = fp:read("*a")

local _M = {}

_M.go = function()

  ngx.header['content-type'] = 'text.html'
  ngx.say(page)

end

return _M
