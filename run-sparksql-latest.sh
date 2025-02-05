#!/usr/bin/env bash

SOURCE_DIR=`dirname "${BASH_SOURCE[0]}"`

SPARKSQL_VERSION=latest $SOURCE_DIR/_run-sparksql.sh
