#! /usr/bin/env bash
cd stacks/reverse-proxies/nginx
docker-compose up & echo "running nginx on localhost:8081, metabase hidden behind, not exposed" 
