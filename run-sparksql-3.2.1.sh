#! /usr/bin/env bash

set -euo pipefail

echo "Removing existing container..."

CONTAINER_NAME=sparksql-3.2.1

docker kill $CONTAINER_NAME 2>/dev/null || echo "Nothing to kill"

docker rm $CONTAINER_NAME 2>/dev/null || echo "Nothing to remove"

docker run -p 10000:10000 \
       --name $CONTAINER_NAME \
       --rm \
       -d metabase/spark:3.2.1

cat <<EOF
Started Spark SQL 3.2.1 on port 10000.

Example JDBC URL:        jdbc:hive2://localhost:10000/?user=admin&password=admin
For a specific database: jdbc:hive2://localhost:10000/test_data?user=admin&password=admin

Note that dashes in test dataset names are replaced with underscores.

No env vars are needed for running Metabase tests. Run the tests:

DRIVERS=sparksql clojure -X:dev:ee:ee-dev:drivers:drivers-dev:test

EOF
