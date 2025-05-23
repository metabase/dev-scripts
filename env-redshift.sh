#! /usr/bin/env bash

set -euo pipefail

item_data=$(op item get "driver: redshift" --vault="Driver Development" --format=json)

DB=$(echo ${item_data} | jq -r '.fields[] | select(.label == "DB").value')
HOST=$(echo ${item_data} | jq -r '.fields[] | select(.label == "HOST").value')
PASSWORD=$(echo ${item_data} | jq -r '.fields[] | select(.label == "PASSWORD").value')
PORT=$(echo ${item_data} | jq -r '.fields[] | select(.label == "PORT").value')
USER=$(echo ${item_data} | jq -r '.fields[] | select(.label == "USER").value')

function print-redshift-vars() {
    cat <<EOF
Java properties:
-Dmb.redshift.test.db=${DB} -Dmb.redshift.test.host=${HOST} -Dmb.redshift.test.password=${PASSWORD} -Dmb.redshift.test.port=${PORT} -Dmb.redshift.test.user=${USER}

Clojure pairs:
:mb-redshift-test-db "${DB}" :mb-redshift-test-host "${HOST}" :mb-redshift-test-password "${PASSWORD}" :mb-redshift-test-port "${PORT}" :mb-redshift-test-user "${USER}"

Bash variables:
MB_REDSHIFT_TEST_DB=${DB} MB_REDSHIFT_TEST_HOST=${HOST}  MB_REDSHIFT_TEST_PASSWORD=${PASSWORD} MB_REDSHIFT_TEST_PORT=${PORT}  MB_REDSHIFT_TEST_USER=${USER}
EOF
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    print-redshift-vars
fi
