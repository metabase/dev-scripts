#!/usr/bin/env bash

SOURCE_DIR=`dirname "${BASH_SOURCE[0]}"`

ORACLE_VERSION=$(curl -s --request GET --url https://endoflife.date/api/oracle-database.json |
jq -r --arg today $(date +%Y%m%d) 'map(select(((.eol == false) or ((.eol | gsub("-";"") | tonumber) > ($today | tonumber))) and (.cycle | tonumber > 19))) | min_by(.cycle) | .cycle')

ORACLE_DB_NAME=XEPDB1
ORACLE_IMAGE=gvenzl/oracle-xe:${ORACLE_VERSION}

if [[ $(uname -m) = arm64 ]]; then
    echo
    echo "WARNING: ${ORACLE_IMAGE} does not support arm64. You might need to run colima or enable emulation to run this image."
    echo
fi

ORACLE_DB_NAME=$ORACLE_DB_NAME ORACLE_IMAGE=$ORACLE_IMAGE $SOURCE_DIR/_run-oracle.sh
