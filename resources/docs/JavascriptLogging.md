# Javascript Error Logging

The stachebox module comes with a separate NPM companion module, `stachebox`, which may be installed to enable Javascript front-end logging, as well: `npm install stachebox`.

Once this module is installed you will need to import the module in to your application's primary Javascript file.

```
import Stachebox from "stachebox";
```

Since the logging API requires authentication, you will need to obtain a token for transmission via one of two methods

## Stachebox Token Authentication

In this method, the front-end user would already be authenticated in to the system with the permission `StacheBoxLog` attached to their user account.  Upon window load, a fetch to the authentication endpoint is requested to obtain a JWT token, which allows the front-end to log errors. This strategy requires that your application implements `cbSecurity` and that you have [overriden the default authentication user service classes in your module configuration](https://stachebox.ortusbooks.com/configuration#authentication).

```javascript
fetch( 
	"/stachebox/api/v1/authentication", 
	{
		method 	: "HEAD"
	} 
).then( response => {
	window.StacheboxLogger = new Stachebox( {
		application : "myApplicationName",
		release : "1.0.1",
		token : response.headers.get( "x-auth-token" ) 
	} );
                
	window.onerror = function( message, source, lineno, colno, error ) {
		if( error ){
			let errorSignature = JSON.stringify( error );
			window.StacheboxLogger.log( error );
		}
	};
} );
```

## Basic Authentication

You may also use basic authentication with credentials to authenticate to the Stachebox API.  This may be the users credentials, or you may create a systemwide account, which only has the `StacheboxLog` permission. To do this, simply skip the fetch for the auth token and configure the logger directly:

```javascript
window.StacheboxLogger = new Stachebox( {
	application : "myApplicationName",
	release : "1.0.1",
	token : btoa( myUsername + ":" + myPassword)
} );
			
window.onerror = function( message, source, lineno, colno, error ) {
	if( error ){
		let errorSignature = JSON.stringify( error );
		window.StacheboxLogger.log( error );
	}
};
```

## Logstash Module Direct API Logging with Token

The `logstash` module is a dependency of the `stachebox` module, and has its own API.  You may configure a token for use only by this module's API endpoing, and use it directly in your logging configuration.  For more information about configuring the Logstash API and tokens, [see the configuration documentation](https://github.com/coldbox-modules/logstash/blob/master/readme.md#configuration).

```javascript
window.StacheboxLogger = new Stachebox( {
	endpoint : "/logstash/api/logs",
	token : window.globalData.logstashAPIToken,
	application : "myApplicationName",
	release : "1.0.1"
} );
			
window.onerror = function( message, source, lineno, colno, error ) {
	if( error ){
		let errorSignature = JSON.stringify( error );
		window.StacheboxLogger.log( error );
	}
};

```

## Ad-Hoc Logging

Once `window.StacheboxLogger` is available, you can use it ad-hoc in other areas of the application to catch and log errors:


```javascript
window.StacheboxLogger.log( {
	level : "ERROR",
	message : "An error occurred while attempting to run some code in my application. More information: Lorem ipsum!",
	event : {
		name :  this.$route.name,
		route : window ? window.location.pathname : "",
		routed_url : window ? window.location.href : "",
		environment : this.$store.globalData.environment
	}
} );