<?php

// Turn off any output buffering
while( ob_get_level() ) ob_end_clean();

//// Initialize error handling ////

ini_set('display_errors','on');
ini_set('error_reporting', E_ALL|E_STRICT);

function coalesce( &$v, $default=null ) {
	return isset($v) ? $v : $default;
}

function dump_error_and_exit( $errno, $errstr, $errfile, $errline, $errcontext ) {
	if( !headers_sent() ) {
		header('Status: 500 Script Error');
		header('Content-Type: text/plain');
	}
	
	echo "Error code=$errno: $errstr\n";
	echo "at $errfile:$errline\n";
	echo "\n";
	echo "Backtrace:\n";
	foreach( debug_backtrace( DEBUG_BACKTRACE_IGNORE_ARGS ) as $item ) {
		echo coalesce($item['file']), ':', $item['line'], "\n";
	}
	exit;
}

// I don't recommend the ErrorException approach mentioned
// on http://us2.php.net/manual/en/class.errorexception.php because
// 1) Errors (almost) always indicate a problem with your code that should be fixed, and
// 2) It can cause problems in contexts where there is no stack frame.
set_error_handler('dump_error_and_exit', E_ALL|E_STRICT);

//// Initialize autoloader ////

require '../vendor/autoload.php';

/**
 * In case other class loaders have failed,
 * try replacing _ with \ and vice-versa.
 * This way a library can use only one style or the other internally.
 */
function eit_autoload_converted( $className ) {
	static $converting;
	
	if( $converting ) return;
	
	$converting = true;
	{
		$bsClassName = str_replace('_', '\\', $className);
		$usClassName = str_replace('\\', '_', $className);
		if( $bsClassName != $className and class_exists($bsClassName, true) ) {
			class_alias($bsClassName, $className);
		} else if( $usClassName != $className and class_exists($usClassName, true) ) {
			class_alias($usClassName, $className);
		}
	}
	$converting = false;
}

spl_autoload_register('eit_autoload_converted');

$registry = new {#projectNamespace}_Registry( '../config' );
$dispatcher = $registry->getComponent('{#projectNamespace}_Dispatcher');
$response = $dispatcher->handleRequest( $_SERVER['PATH_INFO'] );

Nife_Util::outputResponse( $response );
