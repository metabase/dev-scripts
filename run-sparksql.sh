#! /usr/bin/env bash

echo "Removing existing container..."

docker kill sparksql || echo "Nothing to kill"

docker rm sparksql || echo "Nothing to remove"

docker run -p 10000:10000 \
       --name sparksql \
       --rm \
       -d metabase/spark:2.1.1

echo "Started Spark SQL 2.1.1 on port 10000."
