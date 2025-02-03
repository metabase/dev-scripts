#! /usr/bin/env bash

set -euo pipefail

PG_VERSION=17
CONTAINER_NAME=mb-postgres-db
HOST_PORT=${PGSQL_PORT:-5432}
DB_NAME=metabase
DB_USER=metabase
DB_PASSWORD=password
DATA_DIR=$HOME/metabase-pgsql-${PG_VERSION}-data
DOCKER_NETWORK=psql-metabase-network

function print-postgres-vars() {
    cat <<EOF
Java properties:
-Dmb.postgresql.test.host=localhost -Dmb.postgresql.test.port=${HOST_PORT} -Dmb.postgresql.test.db=${DB_NAME} -Dmb.postgresql.test.user=${DB_USER} -Dmb.postgresql.test.password=${DB_PASSWORD}

Clojure pairs:
:mb-postgresql-test-host "localhost" :mb-postgresql-test-port "${HOST_PORT}" :mb-postgresql-test-db "${DB_NAME}" :mb-postgresql-test-user "${DB_USER}" :mb-postgresql-test-password "${DB_PASSWORD}"

Bash variables:
MB_POSTGRESQL_TEST_HOST=localhost MB_POSTGRESQL_TEST_PORT=${HOST_PORT} MB_POSTGRESQL_TEST_DB=${DB_NAME}  MB_POSTGRESQL_TEST_USER=${DB_USER} MB_POSTGRESQL_TEST_PASSWORD=${DB_PASSWORD}
EOF
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    print-postgres-vars
fi
