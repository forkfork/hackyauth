_M = {}

_M.fmt = function(db, sql, arg1, arg2, arg3)
  local res
  local ok, err, errcode, sqlstate = db:connect{
    host = "127.0.0.1",
    port = 3306,
    database = "ngx_test",
    user = "ngx_test",
    password = "ngx_test",
    max_packet_size = 1024 * 1024 }

  if not ok then
    ngx.log(ngx.ERR, "failed to connect: " .. tostring(err) .. ": " .. tostring(errcode) .. " " tostring(sqlstate))
    return "err_db_connection_lost", nil
  end
  local fmted_sql = string.format(sql, 
    arg1 and ngx.quote_sql_str(arg1),
    arg2 and ngx.quote_sql_str(arg2),
    arg3 and ngx.quote_sql_str(arg3))
  res, err, errcode, sqlstate = db:query(fmted_sql)
  if not res then
    ngx.log(ngx.ERR, "failed to query: " .. tostring(err) .. ": " .. tostring(errcode) .. " " tostring(sqlstate))
    return "err_db_sql_failed", nil
  end
  
  return nil, res
end

return _M
