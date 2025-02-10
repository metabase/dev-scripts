#!/usr/bin/env bash

SOURCE_DIR=`dirname "${BASH_SOURCE[0]}"`

MARIADB_VERSION=latest $SOURCE_DIR/_run-mariadb.sh
