#! /usr/bin/env bash

set -euo pipefail

item_data=$(op item get "driver: databricks" --vault="Driver Development" --format=json)

HOST=$(echo ${item_data} | jq -r '.fields[] | select(.label == "HOST").value')
HTTP_PATH=$(echo ${item_data} | jq -r '.fields[] | select(.label == "HTTP_PATH").value')
TOKEN=$(echo ${item_data} | jq -r '.fields[] | select(.label == "TOKEN").value')
CATALOG=$(echo ${item_data} | jq -r '.fields[] | select(.label == "CATALOG").value')

function print-databricks-vars() {
    cat <<EOF
Java properties:
-Dmb.databricks.test.host=${HOST} -Dmb.databricks.test.http.path=${HTTP_PATH} -Dmb.databricks.test.token=${TOKEN} -Dmb.databricks.test.catalog=${CATALOG}

Clojure pairs:
:mb-databricks-test-host "${HOST}" :mb-databricks-test-http-path "${HTTP_PATH}" :mb-databricks-test-token "${TOKEN}" :mb-databricks-test-catalog "${CATALOG}"

Bash variables:
MB_DATABRICKS_TEST_HOST=${HOST}  MB_DATABRICKS_TEST_HTTP_PATH=${HTTP_PATH} MB_DATABRICKS_TEST_TOKEN=${TOKEN} MB_DATABRICKS_TEST_CATALOG=${CATALOG}
EOF
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    print-databricks-vars
fi
