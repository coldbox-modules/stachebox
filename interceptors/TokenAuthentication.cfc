component{

	property name="moduleSettings" inject="coldbox:moduleSettings:stachebox";
	property name="settingService" inject="SettingService@stachebox";
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
				auth().login( getInstance( "UserService@stachebox" ).retrieveUserByUsername( moduleSettings.tokenReporter ) );
				prc.authenticationMethod = "token";
			}


        }  catch ( InvalidCredentials e ) {
            event.overrideEvent( "stachebox:api.v1.Authentication.onAuthenticationFailure" );
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