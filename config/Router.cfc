component{
	function configure(){
		// API Routes
		route( "/api/v1/authentication" )
			.withAction(
				{
					"HEAD" : "head",
					"POST" : "login",
					"DELETE" : "logout"
				}
			).toHandler( "api.v1.Authentication" );

		resources( "/api/v1/logs" ).toHandler( "api.v1.Logs" );
		resources( "/api/v1/users" ).toHandler( "api.v1.Users" );

		route( "/api/v1/authentication" )
			.withAction(
				{
					"HEAD" : "head",
					"POST" : "login",
					"DELETE" : "logout"
				}
			).toHandler( "api.v1.Authentication" );

		// ConventionRoute
		route( "/:handler/:action?" ).end();
	}
}