#! /usr/bin/env bash

set -euo pipefail

SOURCE_DIR=`dirname "${BASH_SOURCE[0]}"`
source "$SOURCE_DIR/common.sh"

CONTAINER_NAME=oracle-21.3

kill-existing $CONTAINER_NAME

docker run -p 1521:1521 -p 2484:2484 \
       --name $CONTAINER_NAME \
       --rm \
       -e ORACLE_PASSWORD=password \
       -d metabase/qa-databases:oracle-xe-21.3

cat <<EOF
Started Oracle Express Edition 21.3.0 on port 1521. Wait 10-20 seconds for it to finish starting.

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
