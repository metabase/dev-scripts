#! /usr/bin/env bash
cd stacks/reverse-proxies
docker-compose up & echo "running haproxy on localhost:8080, nginx on localhost:8081, envoy on localhost:8082, metabase hidden behind, not exposed" 
