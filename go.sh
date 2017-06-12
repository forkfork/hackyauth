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
prove
cat schema.sql | mysql -u tim test
/usr/local/openresty/nginx/sbin/nginx -s reload -p .
sleep 1

echo "Register a valid account"
curl -s -X POST -d '{"org":"evilcorp","name":"tim","email":"user@example.com","password":"hunter2","info":{"a":1}}' http://127.0.0.1:8080/register
echo ""
echo "Login to valid account"

LOGIN=$(curl -s -X POST -d '{"email":"user@example.com","password":"hunter2","org":"evilcorp"}' http://127.0.0.1:8080/login)
echo $LOGIN
TOKEN=$(echo $LOGIN | jq -r .token)
echo "Token returned is $TOKEN"

echo "validate using token: $TOKEN"
curl -s --cookie "access_token=$TOKEN" http://127.0.0.1:8080/validate

echo "register a new org account for org bs"
ORGACCT=$(curl -s -X POST -d '{"org":"smallauth","name":"tim","email":"user@example.com","password":"hunter2","info":{"org":"bs"}}' http://127.0.0.1:8080/register)
echo "Got back a response of $ORGACCT"
ORGACCTTOKEN=$(echo "$ORGACCT" | jq -r .token)
echo "requesting an api key..."
curl -s --cookie "access_token=$ORGACCTTOKEN" -X POST http://127.0.0.1:8080/admin/apikey
exit 0


#curl -s -X POST -d '{"email":"user@example.com","org":"evilcorp"}' http://127.0.0.1:8080/forgot
#TOKEN=$(echo "select token from password_reset;" | mysql -u tim test | tail -n 1)
#echo "token is $TOKEN"

#curl -s -X POST -d "{\"token\":\"$TOKEN\",\"password\":\"hunter3\"}" http://127.0.0.1:8080/reset

#curl -s -X POST -d '{"email":"user@example.com","password":"hunter3","org":"evilcorp"}' \
#  http://127.0.0.1:8080/login

# email is sent

#tail -n 20 ./logs/error.log
