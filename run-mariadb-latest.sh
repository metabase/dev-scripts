#! /usr/bin/env bash

set -euo pipefail

echo "Removing existing container..."

docker kill maria-db-latest 2>/dev/null || echo "Nothing to kill"

docker rm maria-db-latest 2>/dev/null || echo "Nothing to remove"

docker run -p 3306:3306 \
       -e MYSQL_DATABASE=metabase_test \
       -e MYSQL_USER=root \
       -e MYSQL_ALLOW_EMPTY_PASSWORD=yes \
       --name maria-db-latest \
       --rm \
       -d mariadb:latest

cat <<EOF

Started MariaDB latest on port 3306.

JDBC URL: jdbc:mysql://localhost:3306/metabase_test?user=root

env vars: MB_DB_TYPE=mysql MB_DB_DBNAME=metabase_test MB_DB_HOST=localhost MB_DB_PASS='' MB_DB_PORT=3306 MB_DB_USER=root MB_MYSQL_TEST_USER=root

Clojure CLI:

clojure -J-Dmb.db-type=mysql -J-Dmb.db-port=3306 -J-Dmb.db.dbname=metabase_test -J-Dmb.db.user=root -J-Dmb.db.pass=''

or add a profile for it to your ~/.clojure/deps.edn:

{:profiles
 {:user/mysql
  {:jvm-opts
   ["-Dmb.db-type=mysql"
    "-Dmb.db-port=3306"
    "-Dmb.db.dbname=metabase_test"
    "-Dmb.db.user=root"
    "-Dmb.db.pass="]}}}

Connect with the MySQL CLI tool:

mysql --user=root --host=localhost --port=3306 --database=metabase_test

EOF
