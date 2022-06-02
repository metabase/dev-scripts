#!/bin/bash

set -euo pipefail

openssl req -new -text -passout pass:abcd -subj /CN=localhost -out server.req -keyout privkey.pem

openssl rsa -in privkey.pem -passin pass:abcd -out server.key

openssl req -x509 -in server.req -text -key server.key -out server.crt

chmod 600 server.key

test $(uname -s) = Linux && chown 70 server.key

echo '--------------------------------------------------'
echo 'To Connect, Run:'
echo ''
echo 'psql -p 5433 "sslmode=verify-full host=localhost dbname=postgres user=postgres sslrootcert=server.crt"'
echo ''
echo '--------------------------------------------------'

PWD=$(pwd) docker-compose up --force-recreate
