#!/usr/bin/env bash

SOURCE_DIR=`dirname "${BASH_SOURCE[0]}"`

PG_VERSION=latest $SOURCE_DIR/_run-postgres.sh
