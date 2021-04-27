#! /usr/bin/env bash

SOURCE_DIR=`dirname "${BASH_SOURCE[0]}"`
source "$SOURCE_DIR/common.sh"

kill-existing druid-0-17-0

docker run \
       -p 8081:8081 \
       -p 8082:8082 \
       -p 8888:8888 \
       -e CLUSTER_SIZE=nano-quickstart \
       --name druid-0-17-0 \
       --rm \
       -d metabase/druid:0.17.0

echo 'Started Druid on ports 8081, 8082, and 8888.'
echo
echo 'MB_DRUID_TEST_HOST=localhost MB_DRUID_TEST_PORT=8082'
