#! /usr/bin/env bash

set -euo pipefail

CONTAINER_NAME=mb-oracle-db
HOST_PORT=1521
DB_NAME=XEPDB1
DB_USER=system
DB_PASSWORD=password

function print-oracle-vars() {
    cat <<EOF
Java properties:
-Dmb.oracle.test.host=localhost -Dmb.oracle.test.port=${HOST_PORT} -Dmb.oracle.test.service.name=${DB_NAME} -Dmb.oracle.test.user=${DB_USER} -Dmb.oracle.test.password=${DB_PASSWORD}

Clojure pairs:
:mb-oracle-test-host "localhost" :mb-oracle-test-port "${HOST_PORT}" :mb-oracle-test-service-name "${DB_NAME}" :mb-oracle-test-user "${DB_USER}" :mb-oracle-test-password "${DB_PASSWORD}"

Bash variables:
MB_ORACLE_TEST_HOST=localhost MB_ORACLE_TEST_PORT=${HOST_PORT} MB_ORACLE_TEST_SERVICE_NAME=${DB_NAME}  MB_ORACLE_TEST_USER=${DB_USER} MB_ORACLE_TEST_PASSWORD=${DB_PASSWORD}
EOF
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    print-oracle-vars
fi

