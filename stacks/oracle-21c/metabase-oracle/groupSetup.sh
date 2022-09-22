#!/bin/bash

MGID=${MGID:-2000}
MUID=${MUID:-2000}

getent group metabase > /dev/null 2>&1
group_exists=$?

if [ $group_exists -ne 0 ]; then
    addgroup -g $MGID -S metabase
fi
id -u metabase > /dev/null 2>&1
user_exists=$?

if [[ $user_exists -ne 0 ]]; then
    adduser -D -u $MUID -G metabase metabase
fi