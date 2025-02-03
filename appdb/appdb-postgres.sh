#! /usr/bin/env bash

SOURCE_DIR=`dirname "${BASH_SOURCE[0]}"`

source "$SOURCE_DIR/../env-postgres.sh"

cat <<EOF
Environment variables for Metabase (to use as app DB):
MB_DB_TYPE=postgres MB_DB_DBNAME=$DB_NAME MB_DB_HOST=localhost MB_DB_PASS=$DB_PASSWORD MB_DB_PORT=$HOST_PORT MB_DB_USER=$DB_USER MB_POSTGRES_TEST_USER=$DB_USER
EOF
