#! /usr/bin/env bash

echo "Removing existing container..."

docker kill maria-db-latest || echo "Nothing to kill"

docker rm maria-db-latest || echo "Nothing to remove"

docker run -p 3306:3306 \
       -e MYSQL_DATABASE=metabase_test \
       -e MYSQL_USER=root \
       -e MYSQL_ALLOW_EMPTY_PASSWORD=yes \
       --name maria-db-latest \
       --rm \
       -d mariadb:latest
