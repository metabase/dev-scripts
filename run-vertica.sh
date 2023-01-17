#! /usr/bin/env bash

set -euo pipefail

SOURCE_DIR=`dirname "${BASH_SOURCE[0]}"`
source "$SOURCE_DIR/common.sh"

PORT=${VERTICA_PORT:-5433}

ENV=""
if [[ $(uname -m) == 'arm64' ]]; then
    echo "Warning! The database will be likely extremely slow on arm64!"
    ENV+=" --env VERTICA_MEMDEBUG=2"
fi

kill-existing vertica_12_0_2_0

docker run -p ${PORT}:5433 \
       --name vertica_12_0_2_0 \
       --rm \
       $ENV \
       -d vertica/vertica-ce:12.0.2-0

cat <<EOF
Started Vertica 12.0.2-0 on port ${PORT}.

JDBC URL: "jdbc:vertica://localhost:${PORT}/vmart?user=dbadmin"

Env vars:

MB_VERTICA_TEST_HOST=localhost MB_VERTICA_TEST_PORT=${PORT} MB_VERTICA_TEST_USER=dbadmin MB_VERTICA_TEST_PASSWORD="" MB_VERTICA_TEST_DBNAME=vmart
EOF
