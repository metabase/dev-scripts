#!/usr/bin/env bash

SOURCE_DIR=`dirname "${BASH_SOURCE[0]}"`

MYSQL_VERSION=$(curl -s --request GET --url https://endoflife.date/api/mysql.json |
jq -r --arg today $(date +%Y%m%d) 'map(select((.eol == false) or ((.eol | gsub("-";"") | tonumber) > ($today | tonumber)))) | min_by(.cycle) | .cycle')

MYSQL_VERSION=$MYSQL_VERSION $SOURCE_DIR/_run-mysql.sh
