#! /usr/bin/env bash

set -euo pipefail

CONTAINER_NAME=mb-vertica-db
HOST_PORT=5433
DB_NAME=vmart
DB_USER=dbadmin
DB_PASSWORD=''

function print-vertica-vars() {
    cat <<EOF
Java properties:
-Dmb.vertica.test.host=localhost -Dmb.vertica.test.port=${HOST_PORT} -Dmb.vertica.test.dbname=${DB_NAME} -Dmb.vertica.test.user=${DB_USER} -Dmb.vertica.test.password=${DB_PASSWORD}

Clojure pairs:
:mb-vertica-test-host "localhost" :mb-vertica-test-port "${HOST_PORT}" :mb-vertica-test-dbname "${DB_NAME}" :mb-vertica-test-user "${DB_USER}" :mb-vertica-test-password "${DB_PASSWORD}"

Bash variables:
MB_VERTICA_TEST_HOST=localhost MB_VERTICA_TEST_PORT=${HOST_PORT} MB_VERTICA_TEST_DBNAME=${DB_NAME} MB_VERTICA_TEST_USER=${DB_USER} MB_VERTICA_TEST_PASSWORD=${DB_PASSWORD}
EOF
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    print-vertica-vars
fi
