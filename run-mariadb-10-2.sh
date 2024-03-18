#! /usr/bin/env bash

set -euo pipefail

echo "Removing existing container..."

docker kill maria-db-10-2 2>/dev/null || echo "Nothing to kill"

docker rm maria-db-10-2 2>/dev/null || echo "Nothing to remove"

docker run -p 3305:3306 \
       -e MYSQL_DATABASE=metabase_test \
       -e MYSQL_USER=root \
       -e MYSQL_ALLOW_EMPTY_PASSWORD=yes \
       --name maria-db-10-2 \
       --rm \
       -d mariadb:10.2.23

cat <<EOF

Started MariaDB 10.2.23 on port 3305.

JDBC URL: jdbc:mysql://localhost:3305/metabase_test?user=root

env vars: MB_DB_TYPE=mysql MB_DB_DBNAME=metabase_test MB_DB_HOST=localhost MB_DB_PASS='' MB_DB_PORT=3305 MB_DB_USER=root MB_MYSQL_TEST_USER=root

Clojure CLI:

clojure -J-Dmb.db-type=mysql -J-Dmb.db-port=3305 -J-Dmb.db.dbname=metabase_test -J-Dmb.db.user=root -J-Dmb.db.pass=''

or add a profile for it to your ~/.clojure/deps.edn:

{:profiles
 {:user/mysql
  {:jvm-opts
   ["-Dmb.db-type=mysql"
    "-Dmb.db-port=3305"
    "-Dmb.db.dbname=metabase_test"
    "-Dmb.db.user=root"
    "-Dmb.db.pass="]}}}

Connect with the MySQL CLI tool:

mysql --user=root --host=127.0.0.1 --port=3305 --database=metabase_test

EOF

