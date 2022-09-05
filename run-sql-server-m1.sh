#! /usr/bin/env bash

SOURCE_DIR=`dirname "${BASH_SOURCE[0]}"`
source "$SOURCE_DIR/common.sh"

kill-existing sql-server-m1

docker run \
       -p 1433:1433 \
       -e ACCEPT_EULA=Y \
       -e SA_PASSWORD='P@ssw0rd' \
       --name sql-server-m1 \
       --rm \
       -d mcr.microsoft.com/azure-sql-edge

echo 'Started SQL Server 2019 on port 1433.'
echo
echo "MB_SQLSERVER_TEST_HOST=localhost MB_SQLSERVER_TEST_PASSWORD='P@ssw0rd' MB_SQLSERVER_TEST_USER=SA"
