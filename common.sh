#! /usr/bin/env bash

set -eo pipefail

function kill-existing() {
    image_name="$1"

    echo "Removing existing container..."
    docker kill "$image_name" 2>/dev/null || echo "Nothing to kill"
    docker rm "$image_name" 2>/dev/null || echo "Nothing to remove"
}
