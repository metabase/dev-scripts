#! /usr/bin/env bash

SOURCE_DIR=`dirname "${BASH_SOURCE[0]}"`

source "$SOURCE_DIR/env-mysql.sh"

source "$SOURCE_DIR/common.sh"

kill-existing ${CONTAINER_NAME}

docker run -p ${HOST_PORT}:3306 \
       -e MYSQL_DATABASE=${DB_NAME} \
       -e MYSQL_ALLOW_EMPTY_PASSWORD=yes \
       --name ${CONTAINER_NAME} \
       --rm \
       -d mysql:${MYSQL_VERSION}

cat <<EOF

Started MySQL ${MYSQL_VERSION} on port ${HOST_PORT}.

Connect with the MySQL CLI tool:
mysql --user=${DB_USER} --host=127.0.0.1 --port=${HOST_PORT} --database=${DB_NAME}

JDBC URL: jdbc:mysql://localhost:${HOST_PORT}/${DB_NAME}?user=${DB_USER}

EOF

print-mysql-vars
