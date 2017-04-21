echo 'wiping pg'
cat schema.sql | mysql -u tim test
/usr/local/openresty/nginx/sbin/nginx -p . &
echo 'started nginx, waiting 1 sec...'
sleep 1
#curl -X POST -d '{"org":"evilcorp","name":"tim","email":"user@example.com","password":"hunter2"}' http://127.0.0.1:8080/signup
#curl -X POST -d '{"org":"evilcorp","name":"tim","email":"user@example.com","password":"hunter2"}' http://127.0.0.1:8080/signup
#curl -X POST -d '{"email":"user@example.com","password":"hunter2"}' http://127.0.0.1:8080/adminlogin
#curl -X POST -d '{"email":"user@example.com","password":"*******"}' http://127.0.0.1:8080/adminlogin
curl -X POST -d '{"org":"evilcorp","name":"tim","email":"user@example.com","password":"hunter2"}' http://127.0.0.1:8080/register
curl -X POST -d '{"org":"evilcorp","name":"tim","email":"user@example.com","password":"hunter2"}' http://127.0.0.1:8080/register
curl -X POST -d '{"email":"user@example.com","password":"hunter2"}' http://127.0.0.1:8080/login
curl -X POST -d '{"email":"user@example.com","password":"*******"}' http://127.0.0.1:8080/login
skill nginx
