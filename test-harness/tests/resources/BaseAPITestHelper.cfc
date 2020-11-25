component extends="coldbox.system.testing.BaseTestCase"{
	function newEventArgs( method = "GET" ) {

		//clear out all request keys
		for( var key in request ){
			if( findNoCase( "wirebox:", key ) ){
				structDelete( REQUEST, key );
			}
		}

		setup();

		var event = getRequestContext();
		prepareMock( event )
			.$( "getHTTPMethod", arguments.method )
			.$( method = "getHTTPHeader", callback = function( string name ) {
				if ( arguments.name == "X-Requested-With" ){
					return "XMLHttpRequest";
				}
				return "";
			} );

		var rc = event.getCollection();
		var prc = event.getCollection( private=true );


		return {
			"event":event,
			"rc":rc,
			"prc":prc
		};
	}
}