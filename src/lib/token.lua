local uuid = require('lib/uuid')
local ck = require('resty.cookie')

local _M = {}
local expiry_secs = 60 * 60 * 3

local function split4(blob)
  -- takes "a:b:c:d", returns a, b, c:d
  -- doing this in an ugly way for maximum jitting performance
  local pt1 = 1
  local pt2
  pt2 = string.find(blob, ":", 1, true)
  if not pt2 then return nil end
  local str_pt1 = string.sub(blob, pt1, pt2 - 1)
  pt1 = pt2 + 1
  pt2 = string.find(blob, ":", pt2 + 1, true)
  if not pt2 then return nil end
  local str_pt2 = string.sub(blob, pt1, pt2 - 1)
  pt1 = pt2 + 1
  pt2 = string.find(blob, ":", pt2 + 1, true)
  local str_pt3 = string.sub(blob, pt1, pt2 - 1)
  local str_pt4 = string.sub(blob, pt2 + 1)
  return str_pt1, str_pt2, str_pt3, str_pt4
end

_M.create = function(red, user_id, email, org_name, info)
  local ok, err, res, new_token
  local token_blob = user_id .. ":" .. email .. ":" .. org_name .. ":" .. (info or "")
  local res, err = red:get(user_id)
  if res and res ~= ngx.null then
    -- already got a token? reuse it
    new_token = res
  else
    new_token = uuid()
  end
  ngx.log(ngx.ERR, "setting token to " .. token_blob)
  ok, err = red:set(new_token, token_blob, "EX", expiry_secs)
  if not ok then
    ngx.log(ngx.ERR, "unable to save token to redis: " .. tostring(err))
  end
  ok, err = red:set(user_id, new_token, "EX", expiry_secs)
  return new_token
end

_M.validate = function(red, token)
  -- returns email, org, info
  if not token then
    local cookie = ck:new()
    token = cookie:get("access_token")
  end
  ngx.log(ngx.ERR, "GOT A TOKEN of "..token)
  local res, err = red:get(token)
  ngx.log(ngx.ERR, "REDIS HAS "..tostring(res))

  if not res then
    ngx.log(ngx.ERR, "unable to get token from redis: " .. tostring(err))
    return nil
  end
  if res == ngx.null then
    return nil
  end
  return split4(res)

end

_M.test = function()

  --local redis = require "resty.redis"
  --local red = redis.new()
  --local ok, err = red:connect("127.0.0.1", 6379)
  --local tok = _M.create(red, "me@place.com", "awesomeorg", "hihi")
  --a,b,c = _M.validate(red, tok)
  --print(split4("aaa:bbb:ccc:ddd"))

end

return _M
