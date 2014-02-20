var HTTP = require('http');
var URL  = require('url');
var Q    = require('q');
var FS   = require('fs');

var debu = function(t) { process.stderr.write(t); };
var debug = function(t) { debu(t+"\n"); };

var Client = function( baseUri ) {
	this.baseUri = baseUri;
};
Client.prototype.requestJson = function( creds, method, path, data ) {
	if( data ) data = JSON.stringify(data, null, "\t");
		
	var uri = this.baseUri + path;
	debu(method+" "+uri+(creds ? " as "+creds : " anonymously")+"...");
	var reqOpts = URL.parse(uri);
	reqOpts.method = method;
	if( creds ) reqOpts.auth = creds;
	var headers = {};
	if( data ) {
		headers['Content-Type'] = 'application/json';
		headers['Content-Length'] = data.length;
	};
	// headers['Connection'] = 'keep-alive';
	reqOpts.headers = headers;
	
	var deferred = Q.defer();
	var timeoutId = setTimeout(function() { deferred.reject("HTTP request timeout on "+creds+" "+method+" "+path); }, 10000);
	
	var reqInfo = {
		"path": path,
		"uri": uri,
		"method": method,
		"auth": creds,
		"dataObject": data
	};
	
	var req = HTTP.request( reqOpts, function(res) {
		debug(res.statusCode);
		var responseText = '';
		res.on('data', function(d) { responseText += d; });
		res.on('end', function() {
			var ct =  res.headers['content-type'];
			if( ct ) ct = ct.split(';')[0];
			res.data = responseText;
			res.dataObject = ct == 'application/json' ?
				JSON.parse(responseText) : null;
			res.reqInfo = reqInfo;
			deferred.resolve( res );
			clearTimeout(timeoutId);
		});
	});
	req.on('error', function(e) {
		debug("Error!");
		deferred.reject("Error making request to "+method+" "+uri+": "+e);
	});
	if( data ) req.write( data );
	req.end();
	return deferred.promise;
};

var fail = function(message) {
	throw new Error(message);
};

var statusCompatible = function( expected, actual ) {
	 return (expected == actual) || (expected == 200 && actual >= 200 && actual <= 299);
};
	 
var testCount = 0;
var successCount = 0;

var assertStatus = function( expected, creds, method, path, data, testCaseDescription ) {
	++testCount;
	return client.requestJson( creds, method, path, data ).then(
		function( res ) {
			if( !statusCompatible(expected, res.statusCode) ) {
				fail(
					"Expected status "+expected+" but got "+res.statusCode+"\n"+
					"Response data: "+res.data +"\n"+
					"Test case: "+testCaseDescription
				);
			} else ++successCount;
		}
	);
};

var assertEquals = function( expected, actual, failureMessage ) {
	++testCount;
	if( expected != actual ) {
		fail( "expected "+expected+" but got "+actual+" when testing "+failureMessage);
	} else ++successCount;
};

var client;

var npCreds = '';
var userCount = null;

var assertStatus = function( expected, res ) {
	++testCount;
	var req = res.reqInfo;
	if( res.statusCode != expected ) {
		fail(
			"Expected "+req.method+" "+req.uri+" to return status "+expected+", but got "+res.statusCode+"\n"+
			"Response data: "+res.data
		);
	} else {
		++successCount;
	}
};

Q().then(function() {
	var deferred = Q.defer();
	FS.readFile('../config/url.json', function(err, data) { if(err) deferred.reject(err); else deferred.resolve(data); });
	return deferred.promise;
}).then(function(urlConfigData) {
	var urlConfig = JSON.parse(urlConfigData);
	var urlPrefix = urlConfig.deploymentUrlPrefix;
	client = new Client(urlPrefix);
}).then(function() {
	return client.requestJson(null, 'GET', 'users', null).then(function(res) {
		assertStatus(200, res);
		userCount = res.dataObject.length;
	});
}).then(function() {
	return client.requestJson(null, 'GET', 'users/1001', null).then(function(res) {
		assertStatus(200, res);
	});
}).then(function() {
	return client.requestJson(null, 'POST', 'users', {'username': 'bill'}).then(function(res) {
		assertStatus(200, res);
	});
}).then(function() {
	return client.requestJson(null, 'GET', 'users').then(function(res) {
		assertStatus(200, res);
		assertEquals(userCount+1, res.dataObject.length, "new user count");
	});
}).then(function() {
	process.stderr.write(successCount+" / "+testCount + " completed successfully\n");
}).fail(function(error) {
	process.stderr.write(successCount+" / "+testCount + " completed successfully\n");
	process.stderr.write("Error: "+(error.stack ? error.stack : error)+"\n");
	process.exit(1);
});
