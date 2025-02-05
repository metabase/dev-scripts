#!/usr/bin/env bash

SOURCE_DIR=`dirname "${BASH_SOURCE[0]}"`

MONGO_VERSION=latest $SOURCE_DIR/_run-mongo.sh
