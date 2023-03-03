component extends="BaseAPIHandler"{

	// ( HEAD ) /stachebox/api/v1/authentication
	function check( event, rc, prc ){
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
		return this.check( argumentCollection = arguments );
	}

	// ( DELETE ) /stachebox/api/v1/authentication
	function logout( event, rc, prc ){
		auth().logout();
		jwtAuth().logout();
		prc.response.setStatusCode( STATUS.NO_CONTENT );
	}

	// ( POST ) /stachebox/api/v1/authentication/reset
	function resetRequest( event, rc, prc ){
		var userService = getInstance( "UserService@stachebox" );
		param rc.email = "";
		prc.user = userService.retrieveUserByUsername( rc.email );

		if( isNull( prc.user ) ){
			return this.onEntityNotFoundException( argumentCollection = arguments );
		} else {
			userService.processResetRequest( prc.user );
			prc.response.setData( { "acknowleged" : true  } ).setStatusCode( STATUS.CREATED );
		}
	}

	// ( PUT ) /stachebox/api/v1/authentication/reset
	function resetCompletion( event, rc, prc ){
		var jwtService = getInstance( "JWTService@cbsecurity" );
		if( !rc.keyExists( "resetToken" ) || !rc.keyExists( "confirmedPassword" ) ){
			return this.onAuthenticationFailure( argumentCollection = arguments );
		}

		var parsedToken = jwtService.parseToken( token=event.getValue( "resetToken", "" ) );

		prc.user = userService.retrieveUserById( parsedToken.id );

		if( isNull( prc.user ) ){
			return this.onAuthenticationFailure( argumentCollection=arguments );
		}

		prc.user.setPassword( rc.confirmedPassword )
				.encryptPassword()
				.setResetToken( javacast( "null", 0 ) )
				.save();

		prc.response.setData(
			{ "acknowledged" : true }
		).setStatusCode( STATUS.SUCCESS );



	}
}