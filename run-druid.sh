#! /usr/bin/env bash

docker-compose -f stacks/druid/docker-compose.yml up

echo "runing druid console at http://localhost:8888/unified-console.html#"