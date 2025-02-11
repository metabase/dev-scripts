#! /usr/bin/env bash

set -euo pipefail

item_data=$(op item get "driver: bigquery-cloud-sdk" --vault="Driver Development" --format=json)

CLOUD_SDK_TEST_SERVICE_ACCOUNT_JSON=$(echo ${item_data} | jq -r '.fields[] | select(.label == "SERVICE_ACCOUNT_JSON").value')
PROJECT_ID=$(echo ${item_data} | jq -r '.fields[] | select(.label == "PROJECT_ID").value')

function print-bigquery-vars() {
    cat <<EOF
Java properties:
-Dmb.bigquery.cloud.sdk.test.service.account.json=${CLOUD_SDK_TEST_SERVICE_ACCOUNT_JSON} -Dmb.bigquery.test.project.id=${PROJECT_ID}

Clojure pairs:
:mb-bigquery-cloud-sdk-test-service-account-json "${CLOUD_SDK_TEST_SERVICE_ACCOUNT_JSON}" :mb-bigquery-test-project-id "${PROJECT_ID}"

Bash variables:
MB_BIGQUERY_CLOUD_SDK_TEST_SERVICE_ACCOUNT_JSON=${CLOUD_SDK_TEST_SERVICE_ACCOUNT_JSON} MB_BIGQUERY_TEST_PROJECT_ID=${PROJECT_ID}
EOF
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    print-bigquery-vars
fi
