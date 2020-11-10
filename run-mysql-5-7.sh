#! /usr/bin/env bash

SOURCE_DIR=`dirname "${BASH_SOURCE[0]}"`
source "$SOURCE_DIR/common.sh"

kill-existing mysql-5-7

docker run -p 3307:3306 \
       --name mysql-5-7 \
       --rm \
       -d circleci/mysql:5.7.23

echo "Started MySQL 5.7 on port 3307."
echo
echo "jdbc:mysql://localhost:3307/circle_test?user=root"
echo
echo "MB_DB_TYPE=mysql MB_DB_DBNAME=circle_test MB_DB_HOST=localhost MB_DB_PASS='' MB_DB_PORT=3307 MB_DB_USER=root MB_MYSQL_TEST_USER=root"
echo
echo "mysql --user=root --host=127.0.0.1 --port=3307 --database=circle_test"
