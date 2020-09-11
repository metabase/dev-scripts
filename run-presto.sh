#! /usr/bin/env bash

echo "Removing existing container..."

docker kill presto || echo "Nothing to kill"

docker rm presto || echo "Nothing to remove"

docker run -p 8080:8080 \
       --name presto \
       --rm \
       -d metabase/presto-mb-ci

echo "Started Presto on port 8080."
