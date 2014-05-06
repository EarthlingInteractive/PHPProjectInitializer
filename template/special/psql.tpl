#!/bin/sh

export PGPASSWORD={#databasePassword}
exec psql {#databaseName} -U {#databaseUser} -h {#databaseHost} "$@"
