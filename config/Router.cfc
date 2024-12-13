component {

	function configure(){
		route( "/api/logs" )
					.withAction( {
						"HEAD"		: "onInvalidHTTPMethod",
						"OPTIONS"	: "onInvalidHTTPMethod",
						"GET"   	: "onInvalidHTTPMethod",
						"POST"  	: "create",
						"DELETE"	: "onInvalidHTTPMethod",
						"PUT"   	: "create",
						"PATCH" 	: "onInvalidHTTPMethod"
					} )
					.toHandler( "API" );

		apiResources(
			resource = "/api/v1/users",
			handler = "api.v1.Users"
		);
		apiResources(
			resource = "/api/v1/settings",
			handler = "api.v1.Settings"
		);
		apiResources(
			resource = "/api/v1/beats",
			handler = "api.v1.Beats"
		);


		route( "/api/v1/tokens" )
			.withAction( {
				"POST" : "generateToken"
			} )
			.toHandler(  "api.v1.Settings" );

		route( "/api/v1/logs/mappings" )
			.withAction( {
				"POST" : "mappings"
			} )
			.toHandler(  "api.v1.Logs" );

		route( "/api/v1/logs/suppress/:field/:id" )
			.withAction( {
				"DELETE" : "suppress"
			} )
			.toHandler(  "api.v1.Logs" );

		route( '/api/v1/logs/:id' )
			.withAction( {
				"HEAD" : "show",
				"GET" : "show",
				"PUT" : "update",
				"PATCH" : "update",
				"DELETE" : "delete",
				"POST" : "onInvalidHTTPMethod"
			} )
			.toHandler(  "api.v1.Logs" );

		route( '/api/v1/logs' )
			.withAction( {
				"POST" : "index",
				"GET" : "index",
				"HEAD" : "index",
				"PUT" : "create",
				"PATCH" : "onInvalidHTTPMethod",
				"DELETE" : "onInvalidHTTPMethod"
			} )
			.toHandler(  "api.v1.Logs" );

		route( "/api/v1/authentication/reset" )
			.withAction( {
				"POST" : "resetRequest",
				"PUT" : "resetCompletion"
			} )
			.toHandler(  "api.v1.Authentication" );

		route( "/api/v1/authentication" )
			.withAction( {
				"HEAD" : "check",
				"POST" : "login",
				"DELETE" : "logout"
			} )
			.toHandler(  "api.v1.Authentication" );

		route(  "/emailTest" )
			.withAction( "emailTest" )
			.toHandler(  "Main" );

		route( "/" )
			.withAction( "index" )
			.toHandler(  "Main" );

		// Convention Route
		route( "(.*?)" )
			.withAction( "index" )
			.toHandler(  "Main" );
	}

}