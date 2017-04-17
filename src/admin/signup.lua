local sql = require('lib/sql')
local cjson = require('cjson')

_M = {}

local create_query = [[
  INSERT INTO admin (
    org_name,
    name,
    email
  ) VALUES (
    %s,
    %s,
    %s
  );
]]

function create_admin(db, org_name, name, email)

  local err, res = sql.query(db, create_query, org_name, name, email)
  ngx.say(cjson.encode(res))
  
end

_M.go = function(db)
  create_admin(db, "evilcorp", "Timothy Downs", "timothydowns@gmail.com")
end

return _M
