#!/usr/bin/env php
<?php

$dbcConfigFile = __DIR__.'/../config/dbc.json';
$dbcJson = file_get_contents($dbcConfigFile);
if( $dbcJson === false ) {
	fwrite(STDERR, "Error: Failed to open DBC config {$dbcConfigFile}: $errorText\n");
	exit(1);
}
$dbcConfig = json_decode($dbcJson, true);
if( $dbcConfig === null ) {
	fwrite(STDERR, "Error parsing config JSON.");
	exit(1);
}

function coalesce( &$thing, $default ) {
	return isset($thing) ? $thing : $default;
}

$sePassword = escapeshellarg($dbcConfig['password']);
$seHost     = escapeshellarg($dbcConfig['host']);
$sePort     = escapeshellarg(coalesce($dbcConfig['port'], 5432));
$seDatabase = escapeshellarg($dbcConfig['dbname']);
$seUser     = escapeshellarg($dbcConfig['user']);

echo "#!/bin/sh\n";
echo "\n";
echo "export PGPASSWORD={$sePassword}\n";
echo "exec psql {$seDatabase} -U {$seUser} -h {$seHost} -p {$sePort} \"\$@\"\n";
