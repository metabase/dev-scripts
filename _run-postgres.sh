#!/usr/bin/env bash
set -euo pipefail

SOURCE_DIR=`dirname "${BASH_SOURCE[0]}"`

source "$SOURCE_DIR/common.sh"
CONTAINER_NAME=mb-postgres-db-${PG_BROAD_VERSION}
DATA_DIR=${HOME}/metabase-pgsql-${PG_VERSION}-data
DOCKER_NETWORK=psql-metabase-network

kill-existing ${CONTAINER_NAME}
create-network-if-needed ${DOCKER_NETWORK}

docker run \
       -d \
       -p 5432 \
       --network ${DOCKER_NETWORK} \
       -e POSTGRES_USER=mbuser \
       -e POSTGRES_DB=metabase \
       -e POSTGRES_PASSWORD=password \
       -e PGDATA=/var/lib/postgresql/data \
       -v ${DATA_DIR}:/var/lib/postgresql/data:Z \
       --name ${CONTAINER_NAME} \
       postgres:${PG_VERSION}

source ./env-postgres.sh ${PG_BROAD_VERSION}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
       cat << EOF
Started PostgreSQL ${PG_VERSION} on port ${MB_DB_PORT} via Docker (container name: ${CONTAINER_NAME}).
Data will be persisted in ${DATA_DIR} on the host machine (delete it to reset).

To open a SQL client session:
docker run -it --rm --network ${DOCKER_NETWORK} postgres:${PG_VERSION} psql -h ${CONTAINER_NAME} -U ${MB_DB_USER}
And enter the DB user password for ${MB_DB_USER}: ${MB_DB_PASS}

JDBC URL: jdbc:postgres://localhost:${MB_DB_PORT}/${MB_DB_DBNAME}?user=${MB_DB_USER}

EOF

fi
