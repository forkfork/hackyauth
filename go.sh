/usr/local/openresty/nginx/sbin/nginx -p . &
echo 'started nginx, waiting 1 sec...'
sleep 1
curl http://127.0.0.1:8080/
skill nginx
