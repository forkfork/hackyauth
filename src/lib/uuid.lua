local resty_random = require("resty.random")

return function(n_bytes)
  local num_bytes = n_bytes or 8
  return ngx.encode_base64(resty_random.bytes(num_bytes), true)
end
