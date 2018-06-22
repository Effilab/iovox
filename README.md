# IOVOX

# How to use the proxy

1. clone this repository
2. remove/update `.ruby-version`
3. `bundle`
4. prepare `.env` file from `.env.example`
5. obtain `proxy_prod.id_rsa` private key
6. `bin/proxy --prod`
7. in another terminal `bin/console --proxy --target prod`
8. `client = Iovox::Client.new`

