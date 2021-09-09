#! /usr/bin/env bash

set -euo pipefail

CONTAINER_NAME=mb-smtp

echo "Removing existing container..."
docker rm -fv $CONTAINER_NAME 2>/dev/null || echo "Nothing to remove"


docker run \
       -p 1080:80 -p 1025:25 \
       --name $CONTAINER_NAME \
       -d maildev/maildev

cat << EOF
Started SMTP server.

STMP host: localhost
SMTP port: 1025

Web interface: http://localhost:1080
EOF

docker attach $CONTAINER_NAME
