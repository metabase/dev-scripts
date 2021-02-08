#! /usr/bin/env bash
cd stacks/reverse-proxies/haproxy
docker-compose up & echo "running haproxy on localhost:8080, metabase hidden behind, not exposed" 
