local cjson = require('cjson')

return function (code)
  local errs = {
    not_found = {
      status = 404,
      message = "User not found"
    },
    failed_auth = {
      status = 401,
      message = "Password incorrect"
    },
    already_registered = {
      status = 422,
      message = "Email already registered"
    }
  }
  ngx.status = errs[code].status
  ngx.say(cjson.encode(errs[code]))
end
