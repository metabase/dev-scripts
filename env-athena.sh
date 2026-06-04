#! /usr/bin/env bash

set -euo pipefail

item_data=$(op item get "driver: athena" --vault="Driver Development" --format=json)

REGION=$(echo ${item_data} | jq -r '.fields[] | select(.label == "REGION").value')
S3_STAGING_DIR=$(echo ${item_data} | jq -r '.fields[] | select(.label == "S3_STAGING_DIR").value')
ACCESS_KEY=$(echo ${item_data} | jq -r '.fields[] | select(.label == "ACCESS_KEY").value')
SECRET_KEY=$(echo ${item_data} | jq -r '.fields[] | select(.label == "SECRET_KEY").value')

function print-athena-vars() {
    cat <<EOF
Java properties:
-Dmb.athena.test.region=${REGION} -Dmb.athena.test.s3.staging.dir=${S3_STAGING_DIR} -Dmb.athena.test.access.key=${ACCESS_KEY} -Dmb.athena.test.secret.key=${SECRET_KEY}

Clojure pairs:
:mb-athena-test-region "${REGION}" :mb-athena-test-s3-staging-dir "${S3_STAGING_DIR}" :mb-athena-test-access-key "${ACCESS_KEY}" :mb-athena-test-secret-key "${SECRET_KEY}"

Bash variables:
MB_ATHENA_TEST_REGION=${REGION}  MB_ATHENA_TEST_S3_STAGING_DIR=${S3_STAGING_DIR} MB_ATHENA_TEST_ACCESS_KEY=${ACCESS_KEY} MB_ATHENA_TEST_SECRET_KEY=${SECRET_KEY}
EOF
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    print-athena-vars
fi
