#!/usr/bin/env bash

SOURCE_DIR=`dirname "${BASH_SOURCE[0]}"`

PG_VERSION=12 $SOURCE_DIR/_run-postgres.sh
