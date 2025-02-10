#! /usr/bin/env bash

SOURCE_DIR=`dirname "${BASH_SOURCE[0]}"`

source "$SOURCE_DIR/env-mongo.sh"

source "$SOURCE_DIR/common.sh"

kill-existing ${CONTAINER_NAME}

docker run -p ${HOST_PORT}:27017 \
       --name ${CONTAINER_NAME} \
       --rm \
       -d mongo:${MONGO_VERSION}

cat <<EOF

Started MongoDB ${MONGO_VERSION} on port ${HOST_PORT}.

Connect to the database with the MongoDB client:
docker exec -it ${CONTAINER_NAME} mongosh

EOF

print-mongo-vars
