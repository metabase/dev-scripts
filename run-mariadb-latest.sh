#!/usr/bin/env bash

SOURCE_DIR=`dirname "${BASH_SOURCE[0]}"`

MARIADB_BROAD_VERSION=latest MARIADB_VERSION=latest $SOURCE_DIR/_run-mariadb.sh
