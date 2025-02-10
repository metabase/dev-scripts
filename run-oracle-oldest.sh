#!/usr/bin/env bash

SOURCE_DIR=`dirname "${BASH_SOURCE[0]}"`

ORACLE_VERSION=$(curl -s --request GET --url https://endoflife.date/api/oracle-database.json |
jq -r --arg today $(date +%Y%m%d) 'map(select(((.eol == false) or ((.eol | gsub("-";"") | tonumber) > ($today | tonumber))) and (.cycle | tonumber > 19))) | min_by(.cycle) | .cycle')

ORACLE_VERSION=$ORACLE_VERSION $SOURCE_DIR/_run-oracle.sh
