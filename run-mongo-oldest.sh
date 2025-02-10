#!/usr/bin/env bash

SOURCE_DIR=`dirname "${BASH_SOURCE[0]}"`

MONGO_VERSION=$(curl -s --request GET --url https://endoflife.date/api/mongodb.json |
jq -r --arg today $(date +%Y%m%d) 'map(select((.eol == false) or ((.eol | gsub("-";"") | tonumber) > ($today | tonumber)))) | min_by(.cycle) | .cycle')

MONGO_VERSION=$MONGO_VERSION $SOURCE_DIR/_run-mongo.sh
