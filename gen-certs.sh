#!/bin/sh

# temporary password to generate certs only
PASSWORD=`/bin/date +%s`

mkdir -p /certs
cd /certs

echo "[1/3] Generate CA (key & crt) ..."
openssl genrsa -des3 -out ca.key -passout pass:$PASSWORD 4096
openssl rsa -in ca.key -out ca.key -passin pass:$PASSWORD
openssl req -new -x509 -days 365 -key ca.key -out ca.crt -subj "/C=US/ST=Test/L=Test/O=Test/OU=Test/CN=ca"
echo "[1/3] Done"

echo "[2/3] Generate key & crt for server ..."
openssl genrsa -des3 -out server.key -passout pass:$PASSWORD 1024
openssl rsa -in server.key -out server.key -passin pass:$PASSWORD
openssl req -new -key server.key -out server.csr -subj "/C=US/ST=Test/L=Test/O=Test/OU=Test/CN=localhost"
openssl x509 -req -days 365 -in server.csr -CA ca.crt -CAkey ca.key -set_serial 01 -out server.crt
echo "[2/3] Done"

echo "[3/3] Generate key & crt for client ..."
openssl genrsa -des3 -out client.key -passout pass:$PASSWORD 1024
openssl rsa -in client.key -out client.key -passin pass:$PASSWORD
openssl req -new -key client.key -out client.csr -subj "/C=US/ST=Test/L=Test/O=Test/OU=Test/CN=client"
openssl x509 -req -days 365 -in client.csr -CA ca.crt -CAkey ca.key -set_serial 01 -out client.crt
echo "[3/3] Done"
