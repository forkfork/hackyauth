local sql = require('lib/sql')
local cjson = require('cjson.safe')

_M = {}

local create_query = [[
  INSERT INTO admin (
    org,
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
  
  local data = ngx.req.get_body_data()
  local org, name, email
  local params = cjson.decode(data)
  if params then
    org = params.org
    name = params.name
    email = params.email
    create_admin(db, org, name, email)
  else
    ngx.say([[{"code":"provide json body with object {org: org, name: name, email: email}"}]])
  end
end

return _M
