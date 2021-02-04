#! /usr/bin/env bash

docker-compose -f stacks/reverse-proxies/docker-compose.yml

echo "running haproxy on localhost:8080, nginx on localhost:8081, envoy on localhost:8082" 
