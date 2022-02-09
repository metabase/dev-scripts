#! /usr/bin/env bash

set -euo pipefail

echo "Removing existing container..."

CONTAINER_NAME=oracle-18.4

docker kill $CONTAINER_NAME 2>/dev/null || echo "Nothing to kill"

docker rm $CONTAINER_NAME 2>/dev/null || echo "Nothing to remove"

docker run -p 1521:1521 \
       --name $CONTAINER_NAME \
       --rm \
       -e ORACLE_PASSWORD=password \
       -d gvenzl/oracle-xe:18.4.0-slim

cat <<EOF
Started Oracle Express Edition 18.4.0 on port 1521. Wait 10-20 seconds for it to finish starting.

JDBC URL: "jdbc:oracle:thin:@localhost:1521/XEPDB1?user=system&password=password"

Env vars:

MB_ORACLE_TEST_HOST=localhost MB_ORACLE_TEST_USER=system MB_ORACLE_TEST_PASSWORD=password MB_ORACLE_TEST_SERVICE_NAME=XEPDB1

Clojure CLI:

clojure -J-Dmb.oracle.test.host=localhost -J-Dmb.oracle.test.user=system -J-Dmb.oracle.test.password=password -J-Dmb.oracle.test.service.name=XEPDB1

or add a profile for it to your ~/.clojure/deps.edn:

{:profiles
 {:user/oracle
  {:jvm-opts
   ["-Dmb.oracle.test.host=localhost"
    "-Dmb.oracle.test.user=system"
    "-Dmb.oracle.test.password=password"
    "-Dmb.oracle.test.service.name=XEPDB1"]}}}

EOF
