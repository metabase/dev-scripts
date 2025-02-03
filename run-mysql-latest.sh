#! /usr/bin/env bash

set -euo pipefail

SOURCE_DIR=`dirname "${BASH_SOURCE[0]}"`
source "$SOURCE_DIR/common.sh"

CONTAINER_NAME=mysql-latest
HOST_PORT=3308
DB_NAME=metabase_test
DB_USER=root

kill-existing ${CONTAINER_NAME}

docker run -p ${HOST_PORT}:3306 \
       -e MYSQL_DATABASE=${DB_NAME} \
       -e MYSQL_ALLOW_EMPTY_PASSWORD=yes \
       --name ${CONTAINER_NAME} \
       --rm \
       -d mysql:latest

cat <<EOF
Started MySQL Latest on port ${HOST_PORT}.

Clojure CLI:

clj -J-Dmb.db-type=mysql -J-Dmb.db-port=${HOST_PORT} -J-Dmb.db.dbname=${DB_NAME} -J-Dmb.db.user=${DB_USER} -J-Dmb.db.pass=''

or add a profile for it to your ~/.clojure/deps.edn:

{:profiles
 {:user/${CONTAINER_NAME}
  {:jvm-opts
   ["-Dmb.db-type=mysql"
    "-Dmb.db-port=${HOST_PORT}"
    "-Dmb.db.dbname=${DB_NAME}"
    "-Dmb.db.user=${DB_USER}"
    "-Dmb.db.pass="
    "-Dmb.mysql.test.port=${HOST_PORT}"]}}}

Connect with the MySQL CLI tool:

mysql --user=${DB_USER} --host=127.0.0.1 --port=${HOST_PORT} --database=${DB_NAME}

JDBC URL: jdbc:mysql://localhost:${HOST_PORT}/${DB_NAME}?user=${DB_USER}

Environment variables for Metabase (to use as app DB):
MB_DB_TYPE=mysql MB_DB_DBNAME=${DB_NAME} MB_DB_HOST=localhost MB_DB_PASS='' MB_DB_PORT=${HOST_PORT} MB_DB_USER=${DB_USER} MB_MYSQL_TEST_USER=${DB_USER}

Environment variables to use as a data warehouse:
MB_MYSQL_TEST_HOST=localhost MB_MYSQL_TEST_PORT=${HOST_PORT} MB_MYSQL_TEST_DB=${DB_NAME} MB_MYSQL_TEST_USER=${DB_USER} MB_MYSQL_TEST_PASSWORD=''
EOF
