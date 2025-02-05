#! /usr/bin/env bash

SOURCE_DIR=`dirname "${BASH_SOURCE[0]}"`

source "$SOURCE_DIR/../env-mariadb.sh"

cat <<EOF
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
    "-Dmb.db.pass="]}}}

Environment variables for Metabase (to use as app DB):
MB_DB_TYPE=mysql MB_DB_HOST=localhost  MB_DB_PORT=${HOST_PORT} MB_DB_DBNAME=${DB_NAME} MB_DB_USER=${DB_USER} MB_DB_PASS=''
EOF
