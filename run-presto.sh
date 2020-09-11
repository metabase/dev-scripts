#! /usr/bin/env bash

echo "Removing existing container..."

docker kill presto 2>/dev/null || echo "Nothing to kill"

docker rm presto 2>/dev/null || echo "Nothing to remove"

docker run -p 8080:8080 \
       --name presto \
       --rm \
       -d metabase/presto-mb-ci

echo "Started Presto on port 8080."
