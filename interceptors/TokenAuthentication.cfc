component{
	// function preProcess( event, interceptData ){
	// 	if( !auth().check() && ( len( event.getHttpHeader( "x-auth-token", "" ) ) || len( event.getHttpHeader( "Authorization", "" ) ) ) ){
	// 		try{
	// 			jwtAuth().authenticate();
	// 			auth().login( prc.oCurrentUser );
	// 		} catch( TokenExpiredException e ){
	// 			event.overrideEvent( "stachebox:api.v1.BaseAPIHandler.onAuthenticationFailure" );
	// 		} catch( TokenInvalidException e ){
	// 			event.overrideEvent( "stachebox:api.v1.BaseAPIHandler.onAuthenticationFailure" );
	// 		} catch( any e ){
	// 			// if we have another exception we will let the request continue and let cbsecurity sttings pick it up
	// 			return;
	// 		}
	// 	}
	// }
}