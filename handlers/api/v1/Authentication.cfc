component extends="BaseAPIHandler"{

	// ( HEAD ) /stachebox/api/v1/authentication
	function head( event, rc, prc ){
		if( auth().check() ){
			var user = auth().getUser();
			arguments.prc.response.addHeader( "x-auth-user", user.getId() );
			arguments.prc.response.addHeader( "x-auth-token", jwtAuth().fromUser( user ) );
		} else{
			return this.onAuthorizationFailure();
		}
	}

	// ( POST ) /stachebox/api/v1/authentication
	function login( event, rc, prc ){
		param rc.username = "";
		param rc.password = "";

		auth().authenticate( rc.email, rc.password );
		jwtAuth().attempt( rc.email, rc.password );
		prc.response.setStatusCode( STATUS.CREATED );
		return this.head( argumentCollection = arguments );
	}

	// ( DELETE ) /stachebox/api/v1/authentication
	function logout( event, rc, prc ){
		auth().logout();
		// @TODO: Determine if we need to use this too
		// jwtAuth().logout();
		prc.response.setStatusCode( STATUS.NO_CONTENT );
	}
}