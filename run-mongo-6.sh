#! /usr/bin/env bash

set -euo pipefail

echo "Removing existing container..."

docker kill mongo-6 2>/dev/null || echo "Nothing to kill"

docker rm -fv mongo-6 2>/dev/null || echo "Nothing to remove"

docker run -p 27017:27017 \
       --name mongo-6 \
       --rm \
       -d mongo:6.0

cat <<EOF

Started MongoDB 6.0 on Port 27017.

MB_MONGO_TEST_HOST=localhost MB_MONGO_TEST_PORT=27017

Connect to the database with the MongoDB shell:

docker exec -it mongo-6 mongosh

EOF
