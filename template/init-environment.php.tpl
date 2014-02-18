<?php

// This file
// - Initializes autoloaders
// - Initializes some global functions
// - Creates and returns a new {#projectNamespace}_Registry

require 'vendor/autoload.php';

define('{#projectNamespace}_ROOT_DIR', __DIR__);

function eit_get_request_content() {
	static $read;
	static $value;
	 
	if( !$read ) {
		$value = file_get_contents('php://input');
		$read = true;
	}
	return $value;
}

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

return new {#projectNamespace}_Registry( __DIR__.'/config' );
