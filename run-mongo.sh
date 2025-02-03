#! /usr/bin/env bash

set -euo pipefail

SOURCE_DIR=`dirname "${BASH_SOURCE[0]}"`
source "$SOURCE_DIR/common.sh"

CONTAINER_NAME=mongo-4
HOST_PORT=27017

kill-existing ${CONTAINER_NAME}

docker run -p ${HOST_PORT}:27017 \
       --name ${CONTAINER_NAME} \
       --rm \
       -d circleci/mongo:4.2

cat <<EOF

Started MongoDB 4.2 on port ${HOST_PORT}.

Connect to the database with the MongoDB client:

docker exec -it ${CONTAINER_NAME} mongo

Environment variables to use as a data warehouse:
MB_MONGO_TEST_HOST=localhost MB_MONGO_TEST_PORT=${HOST_PORT}
EOF
