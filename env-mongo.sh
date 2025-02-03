#! /usr/bin/env bash

set -euo pipefail

MONGO_VERSION=6
CONTAINER_NAME=mb-mongo-db 
HOST_PORT=27017 

function print-mongo-vars() {
    cat <<EOF
Java properties:
-Dmb.mongo.test.host=localhost -Dmb.mongo.test.port=${HOST_PORT}

Clojure pairs:
:mb-mongo-test-host "localhost" :mb-mongo-test-port "${HOST_PORT}"

Bash variables:
MB_MONGO_TEST_HOST=localhost MB_MONGO_TEST_PORT=${HOST_PORT}
EOF
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    print-mongo-vars
fi
