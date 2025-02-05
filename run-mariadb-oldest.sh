#!/usr/bin/env bash

SOURCE_DIR=`dirname "${BASH_SOURCE[0]}"`

MARIADB_VERSION=$(curl -s --request GET --url https://endoflife.date/api/mariadb.json |
jq -r --arg today $(date +%Y%m%d) 'map(select((.eol == false) or ((.eol | gsub("-";"") | tonumber) > ($today | tonumber)))) | min_by(.cycle) | .cycle')

MARIADB_VERSION=$MARIADB_VERSION $SOURCE_DIR/_run-mariadb.sh
