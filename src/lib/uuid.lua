local resty_random = require("resty.random")

return function()
  return ngx.encode_base64(resty_random.bytes(8), true)
end
