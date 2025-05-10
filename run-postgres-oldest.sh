#!/usr/bin/env bash

SOURCE_DIR=`dirname "${BASH_SOURCE[0]}"`

PG_VERSION=$(curl -s --request GET --url https://endoflife.date/api/postgresql.json |
jq -r --arg today $(date +%Y%m%d) 'map(select((.eol == false) or ((.eol | gsub("-";"") | tonumber) > ($today | tonumber)))) | min_by(.cycle) | .cycle')

PG_BROAD_VERSION=oldest PG_VERSION=$PG_VERSION $SOURCE_DIR/_run-postgres.sh
