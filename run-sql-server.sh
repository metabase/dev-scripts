#! /usr/bin/env bash

docker run -p 1433:1433 -e ACCEPT_EULA='Y' -e SA_PASSWORD='P@ssw0rd' -it mcr.microsoft.com/mssql/server:2017-latest
