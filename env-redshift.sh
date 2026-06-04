#! /usr/bin/env bash

set -euo pipefail

item_data=$(op item get "driver: redshift" --vault="Driver Development" --format=json)

HOST=$(echo ${item_data} | jq -r '.fields[] | select(.label == "HOST").value')
PORT=$(echo ${item_data} | jq -r '.fields[] | select(.label == "PORT").value')
DB=$(echo ${item_data} | jq -r '.fields[] | select(.label == "DB").value')
USER=$(echo ${item_data} | jq -r '.fields[] | select(.label == "USER").value')
PASSWORD=$(echo ${item_data} | jq -r '.fields[] | select(.label == "PASSWORD").value')

function print-redshift-vars() {
    cat <<EOF
Java properties:
-Dmb.redshift.test.host=${HOST} -Dmb.redshift.test.port=${PORT} -Dmb.redshift.test.db=${DB} -Dmb.redshift.test.user=${USER} -Dmb.redshift.test.password=${PASSWORD}

Clojure pairs:
:mb-redshift-test-host "${HOST}" :mb-redshift-test-port "${PORT}" :mb-redshift-test-db "${DB}" :mb-redshift-test-user "${USER}" :mb-redshift-test-password "${PASSWORD}"

Bash variables:
MB_REDSHIFT_TEST_HOST=${HOST}  MB_REDSHIFT_TEST_PORT=${PORT} MB_REDSHIFT_TEST_DB=${DB} MB_REDSHIFT_TEST_USER=${USER} MB_REDSHIFT_TEST_PASSWORD=${PASSWORD}
EOF
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    print-redshift-vars
fi
