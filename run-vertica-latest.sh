#!/usr/bin/env bash

SOURCE_DIR=`dirname "${BASH_SOURCE[0]}"`

VERTICA_VERSION=latest $SOURCE_DIR/_run-vertica.sh
