#! /usr/bin/env bash

SOURCE_DIR=`dirname "${BASH_SOURCE[0]}"`

source "$SOURCE_DIR/env-oracle.sh"

source "$SOURCE_DIR/common.sh"

kill-existing ${CONTAINER_NAME}

docker run -p ${HOST_PORT}:1521 \
       --name ${CONTAINER_NAME} \
       --rm \
       -e ORACLE_PASSWORD=${DB_PASSWORD} \
       -d ${ORACLE_IMAGE}

cat <<EOF

Started ${ORACLE_IMAGE} on port ${HOST_PORT}.
Wait 10-20 seconds for it to finish starting.

JDBC URL: jdbc:oracle:thin:@//localhost:${HOST_PORT}/${DB_NAME}?user=${DB_USER}&password=${DB_PASSWORD}

EOF

print-oracle-vars


