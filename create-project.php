#!/usr/bin/env php
<?php

class EarthIT_PHP_ProjectSetupper {
	public $templateDir;
	public $projectDir;
	public $projectName;
	public $projectNamespace;
	
	public $databaseName;
	public $databaseHost;
	public $databaseUser;
	public $databasePassword;
	public $deploymentUrlPrefix;
	
	public function __construct( $tplDir, $projDir, $projName, $projNamespace ) {
		$this->templateDir = $tplDir;
		$this->projectDir  = $projDir;
		$this->projectName = $projName;
		$this->projectNamespace = $projNamespace;
	}
	
	public function initDefaults() {
		if( $this->templateDir === null ) {
			throw new Exception("No default for template directory.");
		}
		if( $this->projectName === null ) {
			throw new Exception("No default for project name.");
		}
		if( $this->projectDir === null ) {
			throw new Exception("No default for project directory.");
		}
		if( $this->projectNamespace === null ) {
			$fixName = strtr( $this->projectName, array('-'=>' ','/'=>'_','\\'=>'_') );
			$fixName = preg_replace('/[^a-z0-9 _]/i','',$fixName);
			$ucName = ucwords($fixName);
			
			$this->projectNamespace = str_replace(' ','',$ucName);
		}
		$this->deploymentUrlPrefix = 'http://'.preg_replace('/[^a-z0-9]/','',strtolower($this->projectName)).'.localhost/';
		$this->databaseName = preg_replace('/[^a-z0-9]/','',strtolower($this->projectName));
		$this->databaseHost = 'localhost';
		$this->databaseUser = $this->databaseName;
		$this->databasePassword = $this->databaseName;
	}
	
	public function getProjectLibDir() {
		return 'lib/'.str_replace(array('_','\\'),'/',$this->projectNamespace);
	}
	
	protected function templatify( $source, $dest ) {
		if( file_exists($dest) ) return false;
		
		if( is_dir($source) ) {
			$dh = opendir($source);
			while( ($fn = readdir($dh)) !== false ) {
				if( $fn == '.' or $fn == '..' ) continue;
				$subSource = "{$source}/{$fn}";
				if( preg_match('/(.*)\.tpl$/', $fn, $bif) ) {
					$this->templatify( $subSource, "{$dest}/{$bif[1]}" );
				} else if( is_dir($subSource) ) {
					$this->templatify( $subSource, "{$dest}/{$fn}" );
				} else {
					throw new Exception("Unhandled template file: $subSource");
				}
			}
			closedir($dh);
			return;
		}
		
		$c = file_get_contents( $source );
		if( $c === false ) {
			throw new Exception("Failed to read template from file: $source");
		}
		$c = strtr( $c, array(
			'{#projectNamespace}' => $this->projectNamespace,
			'{#projectName}' => $this->projectName,
			'{#projectLibDir}' => $this->getProjectLibDir(),
			'{#databaseName}' => $this->databaseName,
			'{#databaseHost}' => $this->databaseHost,
			'{#databaseUser}' => $this->databaseUser,
			'{#databasePassword}' => $this->databasePassword,
			'{#deploymentUrlPrefix}' => $this->deploymentUrlPrefix
		));
		
		$destDir = dirname($dest);
		if( !is_dir($destDir) ) {
			if( mkdir( $destDir, 0755, true ) === false ) {
				throw new Exception("Failed to create directory: $destDir");
			}
		}
		if( $dest == '-' ) {
			echo $c;
		} else if( file_put_contents( $dest, $c ) === false ) {
			throw new Exception("Failed to write file: $dest");
		}
		
		return true;
	}
	
	public function run() {
		$t = $this->templateDir;
		$p = $this->projectDir;
		$n = $this->projectNamespace;
		$l = $this->getProjectLibDir();
		$dbName = $this->databaseName;
		$this->templatify( $t.'/build',  $p.'/build' );
		$this->templatify( $t.'/config', $p.'/config' );
		$this->templatify( $t.'/lib',    $p.'/'.$l );
		$this->templatify( $t.'/schema', $p.'/schema' );
		$this->templatify( $t.'/www',    $p.'/www' );
		$this->templatify( $t.'/service-tests', $p.'/service-tests' );
		$this->templatify( $t.'/.gitignore.tpl', $p.'/.gitignore' );
		$this->templatify( $t.'/README.md.tpl', $p.'/README.md' );
		$this->templatify( $t.'/Makefile.tpl', $p.'/Makefile' );
		if( $dbName ) {
			$pDbScript = $p.'/util/'.$dbName.'-psql';
			$this->templatify( $t.'/util/psql.tpl', $pDbScript );
			chmod( $pDbScript, 0700 );
		}
		$this->templatify( $t.'/init-www-error-handling.php.tpl', $p.'/init-www-error-handling.php' );
		$this->templatify( $t.'/init-environment.php.tpl', $p.'/init-environment.php' );
		if( $this->templatify( $t.'/composer.json.tpl', $p.'/composer.json' ) ) {
			system('cd '.escapeshellarg($p).' && composer install && make');
		}
		$this->templatify( $t.'/WELCOME.tpl', '-' );
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
	fwrite( STDOUT, "  -i       ; interactive\n" );
	fwrite( STDOUT, "  -o <dir> ; specify output directory (defaults to '.')\n" );
	fwrite( STDOUT, "  -?       ; show help\n" );
	exit(0);
}

if( $projectName === null and !$interactive ) {
	dieForUsageError("Project name must be specified unless in interactive mode");
}

$templateDir = dirname(__FILE__)."/template";

if( $interactive ) {
	$projectName = prompt( "Project name", $projectName );
	$projectDir = prompt( "Project directory", $projectDir );
	$setupper = new EarthIT_PHP_ProjectSetupper( $templateDir, $projectDir, $projectName, $projectNamespace );
	$setupper->initDefaults();
	$setupper->projectNamespace = prompt( "PHP class namespace", $setupper->projectNamespace );
	$setupper->databaseName = prompt( "Database name", $setupper->databaseName );
	$setupper->databaseUser = prompt( "Database user", $setupper->databaseUser );
	$setupper->databaseHost = prompt( "Database host", $setupper->databaseHost );
	$setupper->databasePassword = prompt( "Database password", $setupper->databasePassword );
	$setupper->deploymentUrlPrefix = prompt( "Deployment URL prefix", $setupper->deploymentUrlPrefix );
} else {
	$setupper = new EarthIT_PHP_ProjectSetupper( $templateDir, $projectDir, $projectName, $projectNamespace );
	if( $projectNamespace ) {
		$setupper->projectNamespace = $projectNamespace;
	}
	$setupper->initDefaults();
}
$setupper->run();
