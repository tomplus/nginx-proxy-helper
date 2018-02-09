# nginx-proxy-helper

Smart docker image with nginx preconfigued to terminate SSL or to proxy requests. It's useful when you need to test your applications or libraries. Enjoy !

```

    https, port 443         + ----------------------------+
    ----------------------->|                             |
                            |     nginx-proxy-helper      |                        +-------------|
    ----------------------->|                             |    http://localhost:80 |             |
    https, port 444         |                             |----------------------->| application |
    (verify client's cert)  |                             |                        |             |
                            |                             |                        +-------------+
    ----------------------->|   /certs/ca,server,client   |
    http, port 8080         +-----------------------------|
    proxy                                  |
                                           | http 9000
                                           v download certs
```

## Usage

The image doesn't contain keys or certificates. You have to provide them or generate on the first usage:

```
$ mkdir /tmp/certs

$ docker run --volume /tmp/certs:/certs -it tpimages/nginx-proxy-helper:latest gen-certs.sh
...
[1/3] Generate CA (key & crt) ...
Generating RSA private key, 4096 bit long modulus
........................................................................................................................................................................................++
....................................................................................................................................................................................++
e is 65537 (0x010001)
writing RSA key
[1/3] Done
[2/3] Generate key & crt for server ...
Generating RSA private key, 1024 bit long modulus
..............................................................++++++
.++++++
e is 65537 (0x010001)
writing RSA key
Signature ok
subject=C = US, ST = Test, L = Test, O = Test, OU = Test, CN = localhost
Getting CA Private Key
[2/3] Done
[3/3] Generate key & crt for client ...
Generating RSA private key, 1024 bit long modulus
...++++++
..............++++++
e is 65537 (0x010001)
writing RSA key
Signature ok
subject=C = US, ST = Test, L = Test, O = Test, OU = Test, CN = client
Getting CA Private Key
[3/3] Done

$ ls -lh /tmp/certs
ca.crt  ca.key  client.crt  client.csr  client.key  server.crt  server.csr  server.key
```

Now, you can start the nginx-proxy-helper:

```
$ docker run --network=host --volume /tmp/certs:/certs -it tpimages/nginx-proxy-helper:latest
```
and play:

```
# use https endpoint with generated ca
$ curl --cacert /tmp/certs/ca.crt https://localhost -vs > /dev/null

# use https endpoint with client cers (client.key has 0600 permission)
$ curl --cacert /tmp/certs/ca.crt --cert /tmp/certs/client.crt --key /tmp/certs/client.key -v https://localhost:444

# use proxy
$ http_proxy=http://localhost:8080 curl -v http://localhost
```

## Tips

If you don't have any application on localhost:80, you can use an image with Nginx (it servers the welcome page).

```
$ docker run --network=host nginx:latest
```

In some CI/CD pipelines can be useful to create certs on ephemeral storage. You can do it in this way:

```
docker run --network=host -it tpimages/nginx-proxy-helper:latest /bin/bash -c "gen-certs.sh; nginx"
```

and you can download keys from http://localhost:9000/.

