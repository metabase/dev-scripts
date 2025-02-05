#!/usr/bin/env bash

SOURCE_DIR=`dirname "${BASH_SOURCE[0]}"`

PRESTO_VERSION=0.286 $SOURCE_DIR/_run-presto.sh
