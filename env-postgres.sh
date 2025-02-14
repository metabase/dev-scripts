#!/usr/bin/env bash
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    set -euo pipefail
fi
SOURCE_DIR=`dirname "${BASH_SOURCE[0]}"`
cd "$(dirname "$0")"

if [[ $# -eq 0 ]] && [[ -z "${PG_BROAD_VERSION:-}" ]]; then
    echo "Usage: ./$(basename "$0") [latest/oldest]" >&2
    exit 1
fi
# `oldest` or `latest`
container=mb-postgres-db-${1:-$PG_BROAD_VERSION}
port=$(docker port ${container} 5432/tcp | cut -d: -f2)
source ${SOURCE_DIR}/getenv.sh ${container} POSTGRES_USER POSTGRES_DB POSTGRES_PASSWORD

export MB_DB_TYPE=postgres
export MB_DB_DBNAME=${POSTGRES_DB}
export MB_DB_HOST=127.0.0.1
export MB_DB_PASS=${POSTGRES_PASSWORD}
export MB_DB_PORT=${port}
export MB_DB_USER=${POSTGRES_USER}

export MB_POSTGRESQL_TEST_USER=${MB_DB_USER}
export MB_POSTGRESQL_TEST_PASSWORD=${MB_DB_PASS}
export MB_POSTGRESQL_TEST_DBNAME=${MB_DB_DBNAME}
export MB_POSTGRESQL_TEST_HOST=${MB_DB_HOST}
export MB_POSTGRESQL_TEST_PORT=${MB_DB_PORT}

export PGHOST=${MB_DB_HOST}
export PGPORT=${MB_DB_PORT}
export PGUSER=${MB_DB_USER}
export PGPASSWORD=${MB_DB_PASS}
export PGDATABASE=${MB_DB_DBNAME}

function print-postgres-vars() {
    cat <<EOF
Java properties:
-Dmb.postgresql.test.host=localhost -Dmb.postgresql.test.port=${MB_DB_PORT} -Dmb.postgresql.test.db=${MB_DB_DBNAME} -Dmb.postgresql.test.user=${MB_DB_USER} -Dmb.postgresql.test.password=${MB_DB_PASS}

Clojure pairs:
:mb-postgresql-test-host "localhost" :mb-postgresql-test-port "${MB_DB_PORT}" :mb-postgresql-test-db "${MB_DB_DBNAME}" :mb-postgresql-test-user "${MB_DB_USER}" :mb-postgresql-test-password "${MB_DB_PASS}"

Bash variables:
MB_POSTGRESQL_TEST_HOST=localhost MB_POSTGRESQL_TEST_PORT=${MB_DB_PORT} MB_POSTGRESQL_TEST_DB=${MB_DB_DBNAME}  MB_POSTGRESQL_TEST_USER=${MB_DB_USER} MB_POSTGRESQL_TEST_PASSWORD=${MB_DB_PASS}
EOF
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    print-postgres-vars
fi
