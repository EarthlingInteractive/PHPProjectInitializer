#!/usr/bin/env php
<?php

class EarthIT_PHP_ProjectSetupper {
	public $templateDir;
	public $projectDir;
	public $projectName;
	public $projectNamespace;
	
	public function __construct( $tplDir, $projDir, $projName ) {
		$this->templateDir = $tplDir;
		$this->projectDir  = $projDir;
		$this->projectName = $projName;
		$fixName = strtr( $projName, array('-'=>' ','/'=>'_','\\'=>'_') );
		$fixName = preg_replace('/[^a-z0-9 _]/i','',$fixName);
		
		$ucName = ucwords($fixName);
		$this->projectNamespace = str_replace(' ','',$ucName);
	}
	
	public function getProjectLibDir() {
		return 'lib/'.str_replace(array('_','\\'),'/',$this->projectNamespace);
	}
	
	protected function templatify( $source, $dest ) {
		if( file_exists($dest) ) return false;
		
		$c = file_get_contents( $source );
		if( $c === false ) {
			throw new Exception("Failed to read template from file: $source");
		}
		$c = strtr( $c, array(
			'{#projectNamespace}' => $this->projectNamespace,
			'{#projectName}' => $this->projectName,
			'{#projectLibDir}' => $this->getProjectLibDir(),
		));
		
		$destDir = dirname($dest);
		if( !is_dir($destDir) ) {
			if( mkdir( $destDir, 0755, true ) === false ) {
				throw new Exception("Failed to create directory: $destDir");
			}
		}
		if( file_put_contents( $dest, $c ) === false ) {
			throw new Exception("Failed to write file: $dest");
		}
		
		return true;
	}
	
	public function run() {
		$t = $this->templateDir;
		$p = $this->projectDir;
		$n = $this->projectNamespace;
		$l = $this->getProjectLibDir();
		$this->templatify( $t.'/www/.htaccess.tpl', $p.'/www/.htaccess' );
		$this->templatify( $t.'/www/bootstrap.php.tpl', $p.'/www/bootstrap.php' );
		$this->templatify( $t.'/config/dbc.json.tpl', $p.'/config/dbc.json' );
		$this->templatify( $t.'/lib/Registry.php.tpl', $p.'/'.$l.'/Registry.php' );
		$this->templatify( $t.'/lib/Dispatcher.php.tpl', $p.'/'.$l.'/Dispatcher.php' );
		if( $this->templatify( $t.'/composer.json.tpl', $p.'/composer.json' ) ) {
			system('composer install');
		}
	}
}

# Run this from inside the directory that should contain your project

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
	$input = trim(fgets( STDIN ));
	if( $input == '' ) return $defaultValue;
	return $input;
}

$projectName = null;
$projectNamespace = null;
$interactive = false;
$showHelp = false;
$projectDir = '.';
for( $i=1; $i<$argc; ++$i ) {
	$arg = $argv[$i];
	switch( $arg ) {
	case '-?': case '-h': case '-help': case '--help':
		$showHelp = true;
		break;
	case '-o':
		$projectDir = $argv[++$i];
		break;
	case '-i':
		$interactive = true;
		break;
	default:
		if( $arg[0] != '-' ) {
			if( $projectName === null ) {
				$projectName = $arg;
				break;
			} else if( $projectNamespace === null ) {
				$projectNamespace = $arg;
				break;
			}
		}
		dieForUsageError("Unrecognized argument: '$arg'");
	}
}

if( $showHelp ) {
	fwrite( STDOUT, "Usage: {$argv[0]} [<project name>] [<namespace>] [-i] [-?]\n" );
	fwrite( STDOUT, "Options:\n" );
	fwrite( STDOUT, "  -i ; interactive\n" );
	fwrite( STDOUT, "  -? ; show help\n" );
	exit(0);
}

if( $projectName === null and !$interactive ) {
	dieForUsageError("Project name must be specified unless in interactive mode");
}

$templateDir = dirname(__FILE__)."/template";

if( $interactive ) {
	$projectName = prompt( "Project name", $projectName );
	$projectDir = prompt( "Project directory", $projectDir );
	$setupper = new EarthIT_PHP_ProjectSetupper( $templateDir, $projectDir, $projectName );
	$setupper->projectNamespace = prompt( "PHP class namespace", $setupper->projectNamespace );
} else {
	$setupper = new EarthIT_PHP_ProjectSetupper( $templateDir, $projectDir, $projectName );
	if( $projectNamespace ) {
		$setupper->projectNamespace = $projectNamespace;
	}
}
$setupper->run();
