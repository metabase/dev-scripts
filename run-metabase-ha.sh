#! /usr/bin/env bash
cd stacks/ha
docker-compose up & echo "running metabase in HA mode on localhost:8080 (round robin)" 