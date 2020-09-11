#! /usr/bin/env bash

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

echo "Started MariaDB latest on port 3306."
echo
echo "jdbc:mysql://localhost:3306/metabase_test?user=root"
echo
echo "MB_DB_TYPE=mysql MB_DB_DBNAME=metabase_test MB_DB_HOST=localhost MB_DB_PASS='' MB_DB_PORT=3306 MB_DB_USER=root MB_MYSQL_TEST_USER=root"
echo
echo "mysql --user=root --host=127.0.0.1 --port=3306 --database=metabase_test"
