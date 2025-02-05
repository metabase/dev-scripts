#! /usr/bin/env bash

set -euo pipefail

CONTAINER_NAME=mb-mariadb-db
HOST_PORT=3307
DB_NAME=metabase_test
DB_USER=root

function print-mariadb-vars() {
    cat <<EOF
Java properties:
-Dmb.mysql.test.host=localhost -Dmb.mysql.test.port=${HOST_PORT} -Dmb.mysql.test.db=${DB_NAME} -Dmb.mysql.test.user=${DB_USER} -Dmb.mysql.test.password=

Clojure pairs:
:mb-mysql-test-host "localhost" :mb-mysql-test-port "${HOST_PORT}" :mb-mysql-test-db "${DB_NAME}" :mb-mysql-test-user "${DB_USER}" :mb-mysql-test-password ""

Bash variables:
MB_MYSQL_TEST_HOST=localhost MB_MYSQL_TEST_PORT=${HOST_PORT} MB_MYSQL_TEST_DB=${DB_NAME}  MB_MYSQL_TEST_USER=${DB_USER} MB_MYSQL_TEST_PASSWORD=''
EOF
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    print-mariadb-vars
fi

