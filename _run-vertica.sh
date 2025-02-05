#! /usr/bin/env bash

SOURCE_DIR=`dirname "${BASH_SOURCE[0]}"`

source "$SOURCE_DIR/env-vertica.sh"

source "$SOURCE_DIR/common.sh"

ENV=""
if [[ $(uname -m) == 'arm64' ]]; then
    echo "Warning! The database will be likely extremely slow on arm64!"
    ENV+=" --env VERTICA_MEMDEBUG=2"
fi

kill-existing ${CONTAINER_NAME}

docker run -p ${HOST_PORT}:5433 \
       --name ${CONTAINER_NAME} \
       --rm \
       ${ENV} \
       -d opentext/vertica-ce:${VERTICA_VERSION}

cat <<EOF

Started Vertica ${VERTICA_VERSION} on port ${HOST_PORT}.

JDBC URL: "jdbc:vertica://localhost:${HOST_PORT}/${DB_NAME}?user=${DB_USER}"

EOF

print-vertica-vars
