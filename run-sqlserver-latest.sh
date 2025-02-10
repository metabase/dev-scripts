#!/usr/bin/env bash

SOURCE_DIR=`dirname "${BASH_SOURCE[0]}"`

SQLSERVER_VERSION=2022-latest $SOURCE_DIR/_run-sqlserver.sh
