#! /usr/bin/env bash
cd stacks/reverse-proxies/envoy
docker-compose up & echo "running envoy on localhost:8082, metabase hidden behind, not exposed" 
