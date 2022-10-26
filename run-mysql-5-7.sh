#! /usr/bin/env bash

SOURCE_DIR=`dirname "${BASH_SOURCE[0]}"`
source "$SOURCE_DIR/common.sh"

kill-existing mysql-5-7

docker run -p 3307:3306 \
       --name mysql-5-7 \
       --rm \
       -d circleci/mysql:5.7.23

cat <<EOF
Started MySQL 5.7 on port 3307.

JDBC URL: jdbc:mysql://localhost:3307/circle_test?user=root

env vars: MB_DB_TYPE=mysql MB_DB_DBNAME=circle_test MB_DB_HOST=localhost MB_DB_PASS='' MB_DB_PORT=3307 MB_DB_USER=root MB_MYSQL_TEST_USER=root"

Clojure CLI:

clj -J-Dmb.db-type=mysql -J-Dmb.db-port=3307 -J-Dmb.db.dbname=circle_test -J-Dmb.db.user=root -J-Dmb.db.pass=''

or add a profile for it to your ~/.clojure/deps.edn:

{:profiles
 {:user/mysql-5-7
  {:jvm-opts
   ["-Dmb.db-type=mysql"
    "-Dmb.db-port=3307"
    "-Dmb.db.dbname=circle_test"
    "-Dmb.db.user=root"
    "-Dmb.db.pass="]}}}

Connect with the MySQL CLI tool:

mysql --user=root --host=127.0.0.1 --port=3307 --database=circle_test

EOF
