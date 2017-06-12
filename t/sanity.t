use Test::Nginx::Socket 'no_plan';

our $HttpConfig = qq{
  lua_package_path "/home/tim/git/hackyauth/lib/lualib/?.lua;/home/tim/git/hackyauth/src/?.lua;;";
  lua_package_cpath "/usr/local/openresty-debug/lualib/?.so;/usr/local/openresty/lualib/?.so;;";
};

no_shuffle();
run_tests();

__DATA__

=== TEST 1: register a user
--- http_config eval: $::HttpConfig
--- config
location = /register {
    content_by_lua 'require("main")()';
}
--- request
POST /register
{"org":"evilcorp","name":"tim","email":"user@example.com","password":"hunter2","info":{"a":1}}
--- response_body_like
{"token":".*"}
--- error_code: 200

=== TEST 2: login
--- http_config eval: $::HttpConfig
--- config
location = /login {
    content_by_lua 'require("main")()';
}
--- request
POST /login
{"org":"evilcorp","email":"user@example.com","password":"hunter2"}
--- response_body_like
{"token":".*"}
--- error_code: 200

