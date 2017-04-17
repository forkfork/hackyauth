return function(uri, method, routes)
  for i=1,#routes,3 do
    if routes[i] == uri and routes[i+1] == method then
       routes[i+2]()
    end
  end
end
