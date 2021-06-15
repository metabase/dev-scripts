#! /usr/bin/env bash

set -euo pipefail

echo "Removing existing container..."

docker rm -fv mongo-4 2>/dev/null || echo "Nothing to remove"

docker run -p 27017:27017 \
       --name mongo \
       --rm \
       -d circleci/mongo:4.0

cat <<EOF

Started MongoDB 4.0 on Port 27017.

MB_MONGO_TEST_HOST=localhost MB_MONGO_TEST_PORT=27017

Connect to the database with the MongoDB client:

docker exec -it mongo mongo

EOF
