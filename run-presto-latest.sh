#!/usr/bin/env bash

SOURCE_DIR=`dirname "${BASH_SOURCE[0]}"`

PRESTO_VERSION=latest $SOURCE_DIR/_run-presto.sh
