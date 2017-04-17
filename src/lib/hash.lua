local str = require('resty.string')
local resty_sha1 = require('resty.sha1')

return function(password, salt)
  local sha1 = resty_sha1:new()
  sha1:update(salt .. password)
  local hashed_pwd = str.to_hex(sha1:final())
  return hashed_pwd
end
