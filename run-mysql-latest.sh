#!/usr/bin/env bash

SOURCE_DIR=`dirname "${BASH_SOURCE[0]}"`

MYSQL_BROAD_VERSION=latest MYSQL_VERSION=latest $SOURCE_DIR/_run-mysql.sh
