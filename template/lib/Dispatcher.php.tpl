<?php

class {#phpNamespace}_Dispatcher extends EarthIT_Component
{
	protected static function getRequestContentObject() {
		static $requestRead;
		static $requestContentObject;
		if( !$requestRead ) {
			switch( $_SERVER['REQUEST_METHOD'] ) {
			case 'GET': case 'HEAD':
				$requestContentObject = null;
				break;
			default:
				// TODO: Check headers rather than assuming JSON
				$requestContent = eit_get_request_content();
				$requestContentObject = $requestContent == '' ? null : EarthIT_JSON::decode($requestContent);
			}
			$requestRead = true;
		}
		return $requestContentObject;
	}
	
	protected function getRester( EarthIT_Schema_ResourceClass $resourceClass ) {
		$classNames = array(
			'{#phpNamespace}_'.EarthIT_Schema_WordUtil::toPascalCase($resourceClass->getName()).'RESTer',
			'{#phpNamespace}_RESTer',
			'EarthIT_CMIPREST_RESTer'
		);
		foreach( $classNames as $cn ) {
			$c = $this->registry->getComponent($cn, true);
			if( $c !== null ) return $c;
		}
		throw new Exception("No RESTer!");
	}
	
	public function handleRestRequest( $path ) {
		if( $crReq = EarthIT_CMIPREST_CMIPRESTRequest::parse( $_SERVER['REQUEST_METHOD'], $path, $_REQUEST, self::getRequestContentObject() ) ) {
			$collectionName = $crReq->getResourceCollectionName();
			$resourceClass = $this->registry->getSchema()->getResourceClass( EarthIT_Schema_WordUtil::depluralize($collectionName) );
			return $this->getRester($resourceClass)->handle($crReq);
		} else {
			return null;
		}
	}
	
	public function handleRequest( $path ) {
		// Some demonstration routes; remove and replace with your own
		if( $path == '/' ) {
			$helloUri = "hello/".rawurlencode("{#projectName}");
			$helloUriHtml = htmlspecialchars($helloUri);
			
			$schema = $this->registry->getSchema();
			$classLinks = array();
			foreach( $schema->getResourceClasses() as $rc ) {
				$rcName = $rc->getName().'s'; // TODO: better pluralization.
				$dashName = str_replace(' ','-',strtolower($rcName)); // TODO: standardize this in Schema
				$classLinks[] = "<li><a href=\"".htmlspecialchars($dashName)."\">".htmlspecialchars($rcName)."</a></li>";
			}
			
			
			return Nife_Util::httpResponse( 200,
				"<html><head><title>Woooo</title></head>\n".
				"<body>\n".
				"<h1>Welcome to {#projectName}!</h1>\n".
				"<p>This code was generated by PHP Project Initializer.\n".
				"You probably want to make some modifications.</p>\n".
				"<p>See also: <a href=\"$helloUriHtml\">$helloUriHtml</a></p>\n".
				"<h4>Some REST Services</h4>\n".
				"<ul>\n".implode("\n",$classLinks)."</ul>\n".
				"</body></html>\n",
				"text/html; charset=utf-8"
			);
		} else if( preg_match('<^/hello/(.*)$>', $path, $matchData) ) {
			return Nife_Util::httpResponse( 200, "Hello, ".rawurldecode($matchData[1]).'!' );
		} else if( $path == '/error' ) {
			trigger_error( "An error occurred for demonstrative porpoises.", E_USER_ERROR );
		} else if( $path == '/exception' ) {
			throw new Exception( "You asked for an exception and this is it." );
		} else if( $response = $this->handleRestRequest($path) ) {
			return $response;
		} else {
			return Nife_Util::httpResponse( 404, "I don't know about $path!" );
		}
	}
}
