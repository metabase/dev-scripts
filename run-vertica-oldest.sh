#!/usr/bin/env bash

SOURCE_DIR=`dirname "${BASH_SOURCE[0]}"`

VERTICA_VERSION=23.4.0-0 $SOURCE_DIR/_run-vertica.sh
