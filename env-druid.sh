#! /usr/bin/env bash

set -euo pipefail

CONTAINER_NAME=mb-druid-db
WEB_PORT=8081
HOST_PORT=8082

function print-druid-vars() {
    cat <<EOF
Java properties:
-Dmb.druid.test.host=localhost -Dmb.druid.test.port=${HOST_PORT}

Clojure pairs:
:mb-druid-test-host "localhost" :mb-druid-test-port "${HOST_PORT}"

Bash variables:
MB_DRUID_TEST_HOST=localhost MB_DRUID_TEST_PORT=${HOST_PORT}
EOF
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    print-druid-vars
fi
