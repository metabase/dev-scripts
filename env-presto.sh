#! /usr/bin/env bash

set -euo pipefail

CONTAINER_NAME=mb-presto-db
HOST_PORT=8083
DB_USER=presto
DB_PASSWORD=''
SERVER_CA_PEM_FILE=/tmp/presto-ssl-ca.pem
SERVER_CA_DER_FILE=/tmp/presto-ssl-ca.der
MODIFIED_CACERTS_FILE=/tmp/cacerts-with-presto-ssl.jks

function print-presto-vars() {
    cat <<EOF
Java properties:
-Dmb.presto.jdbc.test.host=localhost -Dmb.presto.jdbc.test.port=${HOST_PORT} -Dmb.presto.jdbc.test.user=${DB_USER} -Dmb.presto.jdbc.test.password=${DB_PASSWORD}

Clojure pairs:
:mb-presto-jdbc-test-host "localhost" :mb-presto-jdbc-test-port "${HOST_PORT}" :mb-presto-jdbc-test-user "${DB_USER}" :mb-presto-jdbc-test-password "${DB_PASSWORD}"

Bash variables:
MB_PRESTO_JDBC_TEST_HOST=localhost MB_PRESTO_JDBC_TEST_PORT=${HOST_PORT} MB_PRESTO_JDBC_TEST_USER=${DB_USER} MB_PRESTO_JDBC_TEST_PASSWORD=${DB_PASSWORD}
EOF
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    print-presto-vars
fi
