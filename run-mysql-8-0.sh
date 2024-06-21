#! /usr/bin/env bash

SOURCE_DIR=`dirname "${BASH_SOURCE[0]}"`
source "$SOURCE_DIR/common.sh"

set -euo pipefail

kill-existing mysql-8-0

docker run -p 3309:3306 \
       -e MYSQL_DATABASE=metabase_test \
       -e MYSQL_ALLOW_EMPTY_PASSWORD=yes \
       --name mysql-8-0 \
       --rm \
       -d mysql:8.0

cat <<EOF
Started MySQL Latest on port 3309.

JDBC URL: jdbc:mysql://localhost:3309/metabase_test?user=root

env vars: MB_DB_TYPE=mysql MB_DB_DBNAME=metabase_test MB_DB_HOST=localhost MB_DB_PASS='' MB_DB_PORT=3309 MB_DB_USER=root MB_MYSQL_TEST_USER=root

Clojure CLI:

clj -J-Dmb.db-type=mysql -J-Dmb.db-port=3309 -J-Dmb.db.dbname=metabase_test -J-Dmb.db.user=root -J-Dmb.db.pass=''

or add a profile for it to your ~/.clojure/deps.edn:

{:profiles
 {:user/mysql-8-0
  {:jvm-opts
   ["-Dmb.db-type=mysql"
    "-Dmb.db-port=3309"
    "-Dmb.db.dbname=metabase_test"
    "-Dmb.db.user=root"
    "-Dmb.db.pass="
    "-Dmb.mysql.test.port=3309"]}}}

Connect with the MySQL CLI tool:

mysql --user=root --host=127.0.0.1 --port=3309 --database=metabase_test

EOF
