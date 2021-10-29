#!/usr/bin/env bash

SOURCE_DIR=`dirname "${BASH_SOURCE[0]}"`

PGSQL_DATA_DIR=$HOME/metabase-pgsql-13-data PG_VERSION=13 $SOURCE_DIR/_run-postgres.sh
