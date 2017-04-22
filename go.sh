echo 'wiping pg'o


decode_base64_url() {
  local len=$((${#1} % 4))
  local result="$1"
  if [ $len -eq 2 ]; then result="$1"'=='
  elif [ $len -eq 3 ]; then result="$1"'=' 
  fi
  echo "$result" | tr '_-' '/+' | openssl enc -d -base64
}

decode_jwt(){
   decode_base64_url $(echo -n $2 | cut -d "." -f $1) | jq .
}


cat schema.sql | mysql -u tim test
/usr/local/openresty/nginx/sbin/nginx -s reload -p .
sleep 1
#curl -X POST -d '{"org":"evilcorp","name":"tim","email":"user@example.com","password":"hunter2"}' http://127.0.0.1:8080/signup
#curl -X POST -d '{"org":"evilcorp","name":"tim","email":"user@example.com","password":"hunter2"}' http://127.0.0.1:8080/signup
#curl -X POST -d '{"email":"user@example.com","password":"hunter2"}' http://127.0.0.1:8080/adminlogin
#curl -X POST -d '{"email":"user@example.com","password":"*******"}' http://127.0.0.1:8080/admi$nlogin
JWT=$(curl -s -X POST -d '{"org":"evilcorp","name":"tim","email":"user@example.com","password":"hunter2"}' http://127.0.0.1:8080/register | jq -r .token)
decode_jwt 2 $JWT
curl -s -X POST -d '{"org":"evilcorp","name":"tim","email":"user@example.com","password":"hunter2"}' http://127.0.0.1:8080/register
curl -s -X POST -d '{"email":"user@example.com","password":"hunter2","org":"evilcorp"}' http://127.0.0.1:8080/login
curl -s -X POST -d '{"email":"user@example.com","password":"*******","org":"evilcorp"}' http://127.0.0.1:8080/login
curl -s -X POST -d '{"email":"user@example.com","password":"hunter2","org":"evilcorp","detail":{"org_name":"test"}}' \
  http://127.0.0.1:8080/login

curl -s --cookie "access_token=$JWT" http://127.0.0.1:8080/validate

#tail -n 20 ./logs/error.log
