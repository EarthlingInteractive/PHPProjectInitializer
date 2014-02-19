<?php

function eit_dump_error_and_exit2( $text, $backtrace, Exception $cause=null ) {
	if( !headers_sent() ) {
		header('HTTP/1.0 500 Script Error');
		header('Status: 500 Script Error');
		header('Content-Type: text/plain');
	}
	echo "{$text}\n";
	foreach( $backtrace as $item ) {
		if( isset($item['file']) || isset($item['line']) ) {
			$f = isset($item['file']) ? $item['file'] : '';
			$l = isset($item['line']) ? $item['line'] : '';
			$u = isset($item['function']) ? $item['function'] : '';
			echo "  " . $f . ($l ? ":{$l}" : '') . ($u ? " in {$u}" : '') . "\n";
		}
	}
	if( $cause != null ) {
		echo "Caused by...\n";
		eit_dump_exception_and_exit($cause);
	}
	exit;
}

function eit_dump_error_and_exit( $errno, $errstr, $errfile, $errline, $errcontext ) {
	eit_dump_error_and_exit2( "Error code=$errno: $errstr", debug_backtrace( false ) );
}

function eit_dump_exception_and_exit( Exception $ex ) {
	eit_dump_error_and_exit2(
		$ex->getMessage(),
		array_merge( array(array('file'=>$ex->getFile(), 'line'=>$ex->getLine())), $ex->getTrace()),
		$ex->getPrevious()
	);
}

// I don't recommend the ErrorException approach mentioned
// on http://us2.php.net/manual/en/class.errorexception.php because
// 1) Errors (almost) always indicate a problem with your code that should be fixed, and
// 2) It can cause problems in contexts where there is no stack frame.
set_error_handler('eit_dump_error_and_exit', E_ALL|E_STRICT);

set_exception_handler('eit_dump_exception_and_exit');