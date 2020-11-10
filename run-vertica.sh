#! /usr/bin/env bash

SOURCE_DIR=`dirname "${BASH_SOURCE[0]}"`
source "$SOURCE_DIR/common.sh"

kill-existing vertica_7_1_1

docker run -p 5433:5433 \
       --name vertica_7_1_1 \
       --rm \
       -d sumitchawla/vertica

echo "Started Vertica 7.1.1 on port 5433."
echo
echo 'jdbc:vertica://localhost:5433/docker?user=dbadmin'
echo
echo 'MB_VERTICA_TEST_HOST=localhost MB_VERTICA_TEST_PORT=5433 MB_VERTICA_TEST_USER=dbadmin MB_VERTICA_TEST_PASSWORD="" MB_VERTICA_TEST_DBNAME=docker'
echo
echo "Be sure to download the Vertica JAR from https://my.vertica.com/download/vertica/client-drivers/ and add it to metabase/plugins if you haven't already."
