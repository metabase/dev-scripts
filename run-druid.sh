#! /usr/bin/env bash

# cd
# git clone https://github.com/apache/druid/

cd ~/druid/distribution/docker

docker-compose -f distribution/docker/docker-compose.yml up
