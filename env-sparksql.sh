#! /usr/bin/env bash

set -euo pipefail

CONTAINER_NAME=mb-sparksql-db
HOST_PORT=10000
DB_NAME=test_data
DB_USER=admin
DB_PASSWORD=admin

function print-sparksql-vars() {
    cat <<EOF
Java properties:
-Dmb.sparksql.test.host=localhost -Dmb.sparksql.test.port=${HOST_PORT} -Dmb.sparksql.test.db=${DB_NAME} -Dmb.sparksql.test.user=${DB_USER} -Dmb.sparksql.test.password=${DB_PASSWORD}

Clojure pairs:
:mb-sparksql-test-host "localhost" :mb-sparksql-test-port "${HOST_PORT}" :mb-sparksql-test-db "${DB_NAME}" :mb-sparksql-test-user "${DB_USER}" :mb-sparksql-test-password "${DB_PASSWORD}"

Bash variables:
MB_SPARKSQL_TEST_HOST=localhost MB_SPARKSQL_TEST_PORT=${HOST_PORT} MB_SPARKSQL_TEST_DB=${DB_NAME}  MB_SPARKSQL_TEST_USER=${DB_USER} MB_SPARKSQL_TEST_PASSWORD=${DB_PASSWORD}
EOF
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    print-sparksql-vars
fi
