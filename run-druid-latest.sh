#!/usr/bin/env bash

SOURCE_DIR=`dirname "${BASH_SOURCE[0]}"`

DRUID_VERSION=29.0.0 $SOURCE_DIR/_run-druid.sh
