#!/usr/bin/env bash

SOURCE_DIR=`dirname "${BASH_SOURCE[0]}"`

ORACLE_DB_NAME=FREEPDB1
ORACLE_IMAGE=gvenzl/oracle-free:latest

ORACLE_DB_NAME=$ORACLE_DB_NAME ORACLE_IMAGE=$ORACLE_IMAGE $SOURCE_DIR/_run-oracle.sh
