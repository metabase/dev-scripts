#!/usr/bin/env bash

SOURCE_DIR=`dirname "${BASH_SOURCE[0]}"`

source "$SOURCE_DIR/env-postgres.sh"

source "$SOURCE_DIR/common.sh"

DATA_DIR=${HOME}/metabase-pgsql-${PG_VERSION}-data
DOCKER_NETWORK=psql-metabase-network

kill-existing ${CONTAINER_NAME}
create-network-if-needed ${DOCKER_NETWORK}

docker run \
       --rm \
       -d \
       -p ${HOST_PORT}:5432 \
       --network ${DOCKER_NETWORK} \
       -e POSTGRES_USER=${DB_USER} \
       -e POSTGRES_DB=${DB_NAME} \
       -e POSTGRES_PASSWORD=${DB_PASSWORD} \
       -e PGDATA=/var/lib/postgresql/data \
       -v ${DATA_DIR}:/var/lib/postgresql/data:Z \
       --name ${CONTAINER_NAME} \
       postgres:${PG_VERSION}

cat << EOF

Started PostgreSQL ${PG_VERSION} on port ${HOST_PORT} via Docker (container name: ${CONTAINER_NAME}).
Data will be persisted in ${DATA_DIR} on the host machine (delete it to reset).

To open a SQL client session:
docker run -it --rm --network ${DOCKER_NETWORK} postgres:${PG_VERSION} psql -h ${CONTAINER_NAME} -U ${DB_USER}
And enter the DB user password for ${DB_USER}: ${DB_PASSWORD}

JDBC URL: jdbc:postgres://localhost:${HOST_PORT}/${DB_NAME}?user=${DB_USER}

EOF

print-postgres-vars
