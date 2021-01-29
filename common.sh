#! /usr/bin/env bash

set -eo pipefail

function kill-existing() {
    image_name="$1"

    echo "Removing existing container..."
    docker kill "$image_name" 2>/dev/null || echo "Nothing to kill"
    docker rm "$image_name" 2>/dev/null || echo "Nothing to remove"
}

function create-network-if-needed() {
    NETWORK_NAME="$1"
    if [ -z $(docker network ls --filter name=^${NETWORK_NAME}$ --format="{{ .Name }}") ] ; then 
         docker network create ${NETWORK_NAME} ; 
    fi
}
