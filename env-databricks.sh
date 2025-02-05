#! /usr/bin/env bash

set -euo pipefail

item_data=$(op item get "driver: databricks" --vault="Driver Development" --format=json)

CATALOG=$(echo ${item_data} | jq -r '.fields[] | select(.label == "CATALOG").value')
HOST=$(echo ${item_data} | jq -r '.fields[] | select(.label == "HOST").value')
HTTP_PATH=$(echo ${item_data} | jq -r '.fields[] | select(.label == "HTTP_PATH").value')
TOKEN=$(echo ${item_data} | jq -r '.fields[] | select(.label == "TOKEN").value')

function print-databricks-vars() {
    cat <<EOF
Java properties:
-Dmb.databricks.test.catalog=${CATALOG} -Dmb.databricks.test.host=${HOST} -Dmb.databricks.test.http.path=${HTTP_PATH} -Dmb.databricks.test.token=${TOKEN}

Clojure pairs:
:mb-databricks-test-catalog "${CATALOG}" :mb-databricks-test-host "${HOST}" :mb-databricks-test-http-path "${HTTP_PATH}" :mb-databricks-test-token "${TOKEN}"

Bash variables:
MB_DATABRICKS_TEST_CATALOG=${CATALOG} MB_DATABRICKS_TEST_HOST=${HOST}  MB_DATABRICKS_TEST_HTTP_PATH=${HTTP_PATH} MB_DATABRICKS_TEST_TOKEN=${TOKEN}
EOF
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    print-databricks-vars
fi
