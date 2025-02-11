#! /usr/bin/env bash

set -euo pipefail

item_data=$(op item get "driver: snowflake" --vault="Driver Development" --format=json)

USER=$(echo ${item_data} | jq -r '.fields[] | select(.label == "USER").value')
ACCOUNT=$(echo ${item_data} | jq -r '.fields[] | select(.label == "ACCOUNT").value')
PASSWORD=$(echo ${item_data} | jq -r '.fields[] | select(.label == "PASSWORD").value')
WAREHOUSE=$(echo ${item_data} | jq -r '.fields[] | select(.label == "WAREHOUSE").value')
DB=$(echo ${item_data} | jq -r '.fields[] | select(.label == "DB").value' | head -n 1)
PK_USER=$(echo ${item_data} | jq -r '.fields[] | select(.label == "PK_USER").value')
PK_PRIVATE_KEY=$(echo ${item_data} | jq -r '.fields[] | select(.label == "PK_PRIVATE_KEY").value')

function print-snowflake-vars() {
    cat <<EOF
Java properties:
-Dmb.snowflake.test.user=${USER} -Dmb.snowflake.test.account=${ACCOUNT} -Dmb.snowflake.test.password=${PASSWORD} -Dmb.snowflake.test.warehouse=${WAREHOUSE} -Dmb.snowflake.test.db=${DB} -Dmb.snowflake.test.pk.user=${PK_USER} -Dmb.snowflake.test.pk.private.key=${PK_PRIVATE_KEY}

Clojure pairs:
:mb-snowflake-test-user "${USER}" :mb-snowflake-test-account "${ACCOUNT}" :mb-snowflake-test-password "${PASSWORD}" :mb-snowflake-test-warehouse "${WAREHOUSE}" :mb-snowflake-test-db "${DB}" :mb-snowflake-test-pk-user "${PK_USER}" :mb-snowflake-test-pk-private-key "${PK_PRIVATE_KEY}"

Bash variables:
MB_SNOWFLAKE_TEST_USER=${USER} MB_SNOWFLAKE_TEST_ACCOUNT=${ACCOUNT} MB_SNOWFLAKE_TEST_PASSWORD=${PASSWORD} MB_SNOWFLAKE_TEST_WAREHOUSE=${WAREHOUSE} MB_SNOWFLAKE_TEST_DB=${DB} MB_SNOWFLAKE_TEST_PK_USER=${PK_USER} MB_SNOWFLAKE_TEST_PK_PRIVATE_KEY=${PK_PRIVATE_KEY}
EOF
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    print-snowflake-vars
fi
