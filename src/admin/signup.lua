local create_query = [[
  INSERT INTO admin (
    org_name,
    name,
    email
  ) VALUES (
    '%s',
    '%s',
    '%s',
    '%s'
  );
]]

function create_admin(db, org_name, name, email)
  create_query
  local fmted_sql = string.format(create_query, org_name, name, email)
  local res, err, errcode, sqlstate = db:query(fmted_sql)
end
