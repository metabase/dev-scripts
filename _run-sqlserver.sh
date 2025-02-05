#! /usr/bin/env bash

SOURCE_DIR=`dirname "${BASH_SOURCE[0]}"`

source "$SOURCE_DIR/env-sqlserver.sh"

source "$SOURCE_DIR/common.sh"

kill-existing ${CONTAINER_NAME} 

docker run \
       -p ${HOST_PORT}:1433 \
       -e ACCEPT_EULA=Y \
       -e SA_PASSWORD=${DB_PASSWORD} \
       --name ${CONTAINER_NAME} \
       --rm \
       -d mcr.microsoft.com/mssql/server:${SQLSERVER_VERSION}

cat <<EOF

Started SQL Server ${SQLSERVER_VERSION} on port ${HOST_PORT}.

EOF

print-sqlserver-vars
