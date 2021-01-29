#!/usr/bin/env bash

SOURCE_DIR=`dirname "${BASH_SOURCE[0]}"`
source "$SOURCE_DIR/common.sh"

CONTAINER_NAME=pgsql-12-metabase
DB_NAME=metabase
DB_USER=metabase
DB_PASSWORD=Password1234
HOST_PORT=${PSGQL_PORT:-5432}
DATA_DIR=${PGSQL_DATA_DIR:-$HOME/metabase-pgsql-data}
DOCKER_NETWORK=psql-metabase-network

kill-existing $CONTAINER_NAME
create-network-if-needed $DOCKER_NETWORK

docker run \
       --rm \
       -d \
       -p $HOST_PORT:5432 \
       --network $DOCKER_NETWORK \
       -e POSTGRES_USER=$DB_USER \
       -e POSTGRES_DB=$DB_NAME \
       -e POSTGRES_PASSWORD=$DB_PASSWORD \
       -e PGDATA=/var/lib/postgresql/data \
       -v $DATA_DIR:/var/lib/postgresql/data:Z \
       --name $CONTAINER_NAME \
       postgres:12

cat << EOF
Started PostgreSQL 12 port $HOST_PORT via Docker (container name: $CONTAINER_NAME). Data will be persisted in $DATA_DIR on the host machine (delete it to reset).

JDBC URL: jdbc:postgres://localhost:$HOST_PORT/$DB_NAME?user=$DB_USER

Environment variables for Metabase (to use as app DB):
MB_DB_TYPE=postgres MB_DB_DBNAME=$DB_NAME MB_DB_HOST=localhost MB_DB_PASS=$DB_PASSWORD MB_DB_PORT=$HOST_PORT MB_DB_USER=$DB_USER MB_POSTGRES_TEST_USER=$DB_USER

To open a SQL client session:
docker run -it --rm --network $DOCKER_NETWORK postgres:12 psql -h $CONTAINER_NAME -U $DB_USER
And enter the DB user password for $DB_USER: $DB_PASSWORD
EOF
