#! /usr/bin/env bash

set -euo pipefail

echo "Removing existing container..."

docker kill mongo-4 2>/dev/null || echo "Nothing to kill"

docker rm -fv mongo-4 2>/dev/null || echo "Nothing to remove"

docker run -p 27017:27017 \
       --name mongo-4 \
       --rm \
       -d circleci/mongo:4.2

cat <<EOF

Started MongoDB 4.2 on Port 27017.

MB_MONGO_TEST_HOST=localhost MB_MONGO_TEST_PORT=27017

Connect to the database with the MongoDB client:

docker exec -it mongo-4 mongo

EOF
