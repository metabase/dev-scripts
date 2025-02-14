#! /usr/bin/env bash
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    set -euo pipefail
fi
SOURCE_DIR=`dirname "${BASH_SOURCE[0]}"`
cd "$(dirname "$0")"

if [[ $# -eq 0 ]] && [[ -z "${MYSQL_BROAD_VERSION:-}" ]]; then
    echo "Usage: ./$(basename "$0") [latest/oldest]" >&2
    exit 1
fi

container=mb-mysql-db-${1:-$MYSQL_BROAD_VERSION}
port=$(docker port ${container} 3306/tcp | cut -d: -f2)
source ${SOURCE_DIR}/getenv.sh ${container} MYSQL_DATABASE MYSQL_USER

export MB_DB_TYPE=mysql
export MB_DB_DBNAME=${MYSQL_DATABASE}
export MB_DB_HOST=127.0.0.1
export MB_DB_PASS=
export MB_DB_PORT=${port}
export MB_DB_USER=${MYSQL_USER}

export MB_MYSQL_TEST_USER=${MB_DB_USER}
export MB_MYSQL_TEST_PASSWORD=
export MB_MYSQL_TEST_DBNAME=${MYSQL_DATABASE}
export MB_MYSQL_TEST_HOST=${MB_DB_HOST}
export MB_MYSQL_TEST_PORT=${MB_DB_PORT}

function print-mysql-vars() {
    cat <<EOF
Java properties:
-Dmb.mysql.test.host=localhost -Dmb.mysql.test.port=${MB_DB_PORT} -Dmb.mysql.test.db=${MB_DB_DBNAME} -Dmb.mysql.test.user=${MB_DB_USER} -Dmb.mysql.test.password=

Clojure pairs:
:mb-mysql-test-host "localhost" :mb-mysql-test-port "${MB_DB_PORT}" :mb-mysql-test-db "${MB_DB_DBNAME}" :mb-mysql-test-user "${MB_DB_USER}" :mb-mysql-test-password ""

Bash variables:
MB_MYSQL_TEST_HOST=localhost MB_MYSQL_TEST_PORT=${MB_DB_PORT} MB_MYSQL_TEST_DB=${MB_DB_DBNAME}  MB_MYSQL_TEST_USER=${MB_DB_USER} MB_MYSQL_TEST_PASSWORD=''
EOF
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    print-mysql-vars
fi
