#! /usr/bin/env bash

SOURCE_DIR=`dirname "${BASH_SOURCE[0]}"`

source "$SOURCE_DIR/common.sh"
CONTAINER_NAME=mb-mariadb-db-${MARIADB_BROAD_VERSION}

kill-existing ${CONTAINER_NAME}

docker run -p 3306 \
       -e MYSQL_DATABASE=metabase \
       -e MYSQL_USER=mbuser \
       -e MYSQL_ALLOW_EMPTY_PASSWORD=yes \
       --name ${CONTAINER_NAME} \
       --rm \
       -d mariadb:${MARIADB_VERSION}

source ./env-mariadb.sh ${MARIADB_BROAD_VERSION}

function print-mariadb-vars() {
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
    print-mariadb-vars
fi
