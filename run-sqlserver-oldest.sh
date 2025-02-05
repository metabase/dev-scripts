#!/usr/bin/env bash

SOURCE_DIR=`dirname "${BASH_SOURCE[0]}"`

SQLSERVER_VERSION=$(curl -s --request GET --url https://endoflife.date/api/mssqlserver.json |
jq -r --arg today $(date +%Y%m%d) 'map(select((.eol == false) or ((.eol | gsub("-";"") | tonumber) > ($today | tonumber)))) | map(select(.releaseLabel | test("^[0-9]{4}$"))) | min_by(.releaseLabel) | .releaseLabel')

SQLSERVER_VERSION=$SQLSERVER_VERSION-latest $SOURCE_DIR/_run-sqlserver.sh
