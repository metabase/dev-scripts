#! /usr/bin/env bash

SOURCE_DIR=`dirname "${BASH_SOURCE[0]}"`

source "$SOURCE_DIR/common.sh"
CONTAINER_NAME=mb-mysql-db-${MYSQL_BROAD_VERSION}

kill-existing ${CONTAINER_NAME}

docker run \
       -p 3306 \
       -e MYSQL_DATABASE=metabase \
       -e MYSQL_USER=mbuser \
       -e MYSQL_ALLOW_EMPTY_PASSWORD=yes \
       --name ${CONTAINER_NAME} \
       --rm \
       -d mysql:${MYSQL_VERSION}

source ./env-mysql.sh ${MYSQL_BROAD_VERSION}

cat <<EOF

Started MySQL ${MYSQL_VERSION} on port ${MB_DB_PORT}.

Connect with the MySQL CLI tool:
mysql --user=${MB_DB_USER} --host=127.0.0.1 --port=${MB_DB_PORT} --database=${MB_DB_DBNAME}

JDBC URL: jdbc:mysql://localhost:${MB_DB_PORT}/${MB_DB_DBNAME}?user=${MB_DB_USER}

EOF
