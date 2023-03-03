component{

	property name="moduleSettings" inject="coldbox:moduleSettings:stachebox";
	property name="settingService" inject="SettingService@stachebox";
	property name="jwtService" inject="JWTService@cbsecurity";
	property name="cache" inject="cachebox:template";

	/**
	* If a Basic authentication header exists, attempts to log the user in.
	* If the credentials are invalid, logs any currently logged in user out.
	**/
	void function onRequestCapture( event, rc, prc, interceptData, buffer ) {
        var authorization = event.getHTTPHeader( "Authorization", "" );

        if ( ! len( authorization ) || listFirst( authorization, " " ) != 'Bearer' ) { return; }

        try{
            var token = listLast( authorization, " " );

			var validTokens = settingService.getByName( "apiTokens" ).getMemento();

			if( validTokens.value.contains( token ) ){
				var jwtSettings = jwtService.getSettings().jwt;
				try{
					// do not verify the token since the signature may have changed since it was generated
					var parsedToken = jwtService.getJwt().decode(
						token = token,
						verify = false
					);
				} catch( any e ){
					throw( type="TokenDecodeException", message="The token provided was not valid. Failed to decode token. Have your application settings recently changed?" );
				}
				if( isNull( parsedToken.exp ) || parsedToken.exp > now() ){
					var authUser = getInstance( "UserService@stachebox" ).retrieveUserById( parsedToken.id );
					if( !isNull( authUser ) || authUser.getIsActive() ){
						auth().login( authUser );
						prc.authenticationMethod = "token";
					} else {
						throw( type="InvalidCredentials", message="The token provided was not valid.  The user associated with the account does not exist." );
					}
				} else {
					throw( type="InvalidCredentials", message="The token provided has expired" );
				}
			}


        }  catch ( InvalidCredentials e ) {
            event.overrideEvent( "stachebox:api.v1.Authentication.onAuthenticationFailure" );
		} catch( TokenDecodeException e ) {
			rethrow;
        } catch( any e ){
            // skip out and let subsequent interceptions handle the auth failure
            return;
        }
    }

	void function postProcess( event, rc, prc ){
		if( prc.keyExists( "authenticationMethod" ) && prc.authenticationMethod == "token" ){
			auth().logout()
		}
	}
}