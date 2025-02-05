#! /usr/bin/env bash

set -euo pipefail

SOURCE_DIR=`dirname "${BASH_SOURCE[0]}"`

source "$SOURCE_DIR/env-sparksql.sh"

source "$SOURCE_DIR/common.sh"

kill-existing ${CONTAINER_NAME}

docker run -p ${HOST_PORT}:10000 \
       --name ${CONTAINER_NAME} \
       --rm \
       -d metabase/spark:${SPARKSQL_VERSION}

cat <<EOF

Started Spark SQL ${SPARKSQL_VERSION} on port ${HOST_PORT}.

JDBC URL:                jdbc:hive2://localhost:${HOST_PORT}/?user=${DB_USER}&password=${DB_PASSWORD}
For a specific database: jdbc:hive2://localhost:${HOST_PORT}/${DB_NAME}?user=${DB_USER}&password=${DB_PASSWORD}

EOF
