return function(uri, method, routes, db, red)
  ngx.req.read_body()
  for i=1,#routes,3 do
    if routes[i] == uri and routes[i+1] == method then
       routes[i+2](db, red)
    end
  end
end
