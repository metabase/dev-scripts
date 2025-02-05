#! /usr/bin/env bash

SOURCE_DIR=`dirname "${BASH_SOURCE[0]}"`

source "$SOURCE_DIR/env-druid.sh"

source "$SOURCE_DIR/common.sh"

kill-existing ${CONTAINER_NAME}
docker run \
       -p ${WEB_PORT}:8081 \
       -p ${HOST_PORT}:8082 \
       -p 8888:8888 \
       -e CLUSTER_SIZE=nano-quickstart \
       --name ${CONTAINER_NAME} \
       --rm \
       -d metabase/druid:${DRUID_VERSION}

cat <<EOF

Started Druid ${DRUID_VERSION} on ports ${WEB_PORT}, ${HOST_PORT}, and 8888.

Visit http://localhost:${WEB_PORT} in your browser to view the web console.

EOF

print-druid-vars
