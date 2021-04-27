#! /usr/bin/env bash

SOURCE_DIR=`dirname "${BASH_SOURCE[0]}"`
source "$SOURCE_DIR/common.sh"

kill-existing sql-server-2017

docker run \
       -p 1433:1433 \
       -e ACCEPT_EULA=Y \
       -e SA_PASSWORD='P@ssw0rd' \
       --name sql-server-2017 \
       --rm \
       -d mcr.microsoft.com/mssql/server:2017-latest

echo 'Started SQL Server 2017 on port 1433.'
echo
echo "MB_SQLSERVER_TEST_HOST=localhost MB_SQLSERVER_TEST_PASSWORD='P@ssw0rd' MB_SQLSERVER_TEST_USER=SA"
