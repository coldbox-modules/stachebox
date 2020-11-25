component{
	function preProcess( event, interceptData ){
		try{
			jwtAuth().parseToken();
			jwtAuth().authenticate();
		} catch( TokenExpiredException e ){
			event.overrideEvent( "stachebox:api/v1/BaseAPIHandler.onAuthenticationFailed" );
		} catch( TokenInvalidException e ){
			event.overrideEvent( "stachebox:api/v1/BaseAPIHandler.onAuthenticationFailed" );
		} catch( any e ){
			// if we have another exception we will let the request continue and let cbsecurity sttings pick it up
			return;
		}
	}
}