#!/usr/bin/env php
<?php

require_once __DIR__.'/vendor/autoload.php';

function _defalt( array &$a, $k, $defaultValue ) {
	if( !isset($a[$k]) ) $a[$k] = $defaultValue;
 }

function defaultSettings( array $settings ) {
	if( !isset($settings['projectName']) ) {
		throw new Exception("Can't generate default project settings without projectName");
	}
	$littleProjectName = preg_replace('/[^a-z0-9]/','',strtolower($settings['projectName']));
	
	if( !isset($settings['phpNamespace']) ) {
		$fixName = strtr( $settings['projectName'], array('-'=>' ','/'=>'_','\\'=>'_') );
		$fixName = preg_replace('/[^a-z0-9 _]/i','',$fixName);
		$ucName = ucwords($fixName);
		
		$settings['phpNamespace'] = str_replace(' ','',$ucName);
	}
	
	_defalt($settings, 'nodePackageNamePrefix', preg_replace('/[^a-z0-9-]/','',str_replace(' ','-',strtolower($settings['projectName']))));
	_defalt($settings, 'deploymentUrlPrefix', 'http://'.preg_replace('/[^a-z0-9]/','',strtolower($settings['projectName'])).'.localhost/');
	_defalt($settings, 'databaseName', $littleProjectName);
	_defalt($settings, 'databaseHost', 'localhost');
	_defalt($settings, 'databaseUser', $settings['databaseName']);
	_defalt($settings, 'databasePassword', $settings['databaseName']);
	_defalt($settings, 'databaseObjectPrefix', '');
	return $settings;
}

function defaultSettingsMetadata() {
	$titles = array(
		'project name',
		'PHP namespace',
		'database name',
		'database host',
		'database user',
		'database password',
		'deployment URL prefix',
		'database object prefix'
	);
	$md = array();
	foreach( $titles as $t ) {
		$md[EarthIT_Schema_WordUtil::toCamelCase($t)] = array('title'=>$t);
	}
	return $md;
}

function generateSettingsMetadata(array $settings, array $dmd=null) {
	if( $dmd === null ) $dmd = defaultSettingsMetadata();
	$md = array();
	foreach( $settings as $k=>$v ) {
		if( is_array($v) ) continue;
		$md[$k] = isset($dmd[$k]) ? $dmd[$k] : array('title'=>$k);
	}
	return $md;
}

function dieForUsageError( $message ) {
	global $argv;
	fwrite( STDERR, "Error: $message\n" );
	fwrite( STDERR, "Run '{$argv[0]} -?' for usage information\n" );
	exit(1);
}

function prompt( $name, $defaultValue='' ) {
	echo "$name";
	if( $defaultValue ) echo " [$defaultValue]";
	echo "> ";
	$line = fgets( STDIN );
	$input = trim($line);
	if( $input == '\\' ) return '';
	if( $input == '' ) return $defaultValue;
	return $input;
}

function dumpProjectSettingsKeys( $stream ) {
	foreach( get_class_vars('EarthIT_PHP_ProjectSetupper_ProjectSettings') as $k=>$v ) {
		fwrite( $stream, "  $k\n" );
	}
}

// TODO: Refactor ProjectSetupper constructor to take a ProjectSettings
// and allow settings to be given on the command-line

$templateProjectDir = null;
$outputProjectDir = null;
$projectName = null;
$phpNamespace = null;
$interactive = false;
$showHelp = false;
$overwrite = false;
$makeTargetsToBuild = array();
$settings = array();
for( $i=1; $i<$argc; ++$i ) {
	$arg = $argv[$i];
	switch( $arg ) {
	case '-?': case '-h': case '-help': case '--help':
		$showHelp = true;
		break;
	case '-o':
		$outputProjectDir = $argv[++$i];
		break;
	case '-t':
		$templateProjectDir = $argv[++$i];
		break;
	case '-i':
		$interactive = true;
		break;
	case '--drop-database':
		$makeTargetsToBuild[] = 'drop-database';
		break;
	case '--create-database':
		$makeTargetsToBuild[] = 'create-database';
		break;
	case '--run-tests':
		$makeTargetsToBuild[] = 'run-tests';
		break;
	case '--make':
		$makeTargetsToBuild[] = $argv[++$i];
		break;
	case '--overwrite':
		$overwrite = true;
		break;
	default:
		if( $arg[0] != '-' ) {
			if( preg_match('/^(.+?)=(.*)$/',$arg,$bif) ) {
				$settings[$bif[1]] = $bif[2];
				break;
			} else if( $projectName === null ) {
				$projectName = $arg;
				break;
			} else if( $phpNamespace === null ) {
				$phpNamespace = $arg;
				break;
			}
		}
		dieForUsageError("Unrecognized argument: '$arg'");
	}
}

$usageText = 
	"Usage: {$argv[0]} [<project name>] [<namespace>] [-i] [-?]\n".
	"General options:\n".
	"  -i       ; interactive\n".
	"  -t <dir> ; specify template directory\n".
	"  -o <dir> ; specify output directory (defaults to '.')\n".
	"  -?       ; show help\n".
	"Build options:\n".
	"  --make <target>   ; build a Make target on the new project\n".
	"  --drop-database   ; Short for --make drop-database\n".
	"  --create-database ; Short for --make create-database\n".
	"  --run-tests       ; Short for --make run-tests\n";

if( $showHelp ) {
	fwrite( STDOUT, $usageText );
	exit(0);
}

if( $templateProjectDir === null ) {
	$templateProjectDir = __DIR__.'/vendor/earthit/php-template-project';
}
if( $projectName === null and !$interactive ) {
	dieForUsageError("Project name must be specified unless in interactive mode");
}
if( $outputProjectDir === null and !$interactive ) {
	dieForUsageError("Project directory must be specified unless in interactive mode");
}

if( !is_dir($templateProjectDir) ) {
	dieForUsageError("Template directory '{$templateProjectDir}' does not exist.");
}

$templateProject = new EarthIT_PHPProjectRewriter_Project($templateProjectDir);
$templateProjectSettings = $templateProject->getConfig();

$templateSettingsMetadataFile = "{$templateProjectDir}/.ppi-settings-metadata.json";
if( file_exists($templateSettingsMetadataFile) ) {
	$settingsMetadata = json_decode(file_get_contents($settingsMetadataFile),true);
} else {
	$settingsMetadata = null;
}
$settingsMetadata = generateSettingsMetadata($templateProjectSettings, $settingsMetadata);


$outputSettingsFile = "{$outputProjectDir}/.ppi-settings.json";
if( file_exists($outputSettingsFile) ) {
	$outputProjectSettings = json_decode(file_get_contents($outputSettingsFile),true);
} else {
	$outputProjectSettings = array();
}
$outputProjectSettings['projectName'] = $projectName;

if( $interactive ) {
	echo
		"Hit enter to accept [default values].\n",
		"Enter a single backslash to indicate 'empty string'\n";
	$outputProjectDir = prompt( "Project directory", $outputProjectDir );
	$outputProjectSettings['projectName'] = prompt( "Project name", $outputProjectSettings['projectName'] );
	$outputProjectSettings = defaultSettings($outputProjectSettings);
	foreach( $settingsMetadata as $k=>$info ) {
		if( $k == 'projectName' ) continue; // Already asked!
		$outputProjectSettings[$k] = prompt( $info['title'], $outputProjectSettings[$k] );
	}
} else {
	$outputProjectSettings = defaultSettings($outputProjectSettings);
}

foreach( $templateProjectSettings as $k=>$v ) {
	// Anything setting not explicitly defined should default to the
	// template project's value.
	_defalt($outputProjectSettings, $k, $v);
}

if( !is_dir($outputProjectDir) ) mkdir($outputProjectDir, 0755, true);

file_put_contents($outputSettingsFile, EarthIT_JSON::prettyEncode($outputProjectSettings)."\n");

$outputProject = new EarthIT_PHPProjectRewriter_Project($outputProjectDir, $outputProjectSettings);

$rewriter = new EarthIT_PHPProjectRewriter();
$rewriter->rewrite( $templateProject, $outputProject );

// Make default config files
if( is_dir($outputProjectConfigDir = "{$outputProjectDir}/config") ) {
	$dh = opendir($outputProjectConfigDir);
	while( ($fn = readdir($dh)) !== false ) {
		echo $fn,"\n";
		if( preg_match('/^(.*?)\.example$/',$fn,$bif) and !file_exists("{$outputProjectConfigDir}/{$bif[1]}") ) {
			copy("{$outputProjectConfigDir}/{$fn}", "{$outputProjectConfigDir}/{$bif[1]}");
		}
	}
	closedir($dh);
}

if( $makeTargetsToBuild ) {
	system("make -C ".escapeshellarg($outputProjectDir)." ".implode(' ',$makeTargetsToBuild));
}
