#! /usr/bin/env bash

set -euo pipefail

CONTAINER_NAME=mb-sqlserver-db
HOST_PORT=1433 
DB_NAME=master 
DB_USER=sa
DB_PASSWORD=P@ssw0rd 

function print-sqlserver-vars() {
    cat <<EOF
Java properties:
-Dmb.sqlserver.test.host=localhost -Dmb.sqlserver.test.port=${HOST_PORT} -Dmb.sqlserver.test.db=${DB_NAME} -Dmb.sqlserver.test.user=${DB_USER} -Dmb.sqlserver.test.password=${DB_PASSWORD}

Clojure pairs:
:mb-sqlserver-test-host "localhost" :mb-sqlserver-test-port "${HOST_PORT}" :mb-sqlserver-test-db "${DB_NAME}" :mb-sqlserver-test-user "${DB_USER}" :mb-sqlserver-test-password "${DB_PASSWORD}"

Bash variables:
MB_SQLSERVER_TEST_HOST=localhost MB_SQLSERVER_TEST_PORT=${HOST_PORT} MB_SQLSERVER_TEST_DB=${DB_NAME}  MB_SQLSERVER_TEST_USER=${DB_USER} MB_SQLSERVER_TEST_PASSWORD=${DB_PASSWORD}
EOF
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    print-sqlserver-vars
fi
