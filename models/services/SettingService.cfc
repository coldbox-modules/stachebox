component singleton {

	property name="moduleSettings" inject="coldbox:moduleSettings:stachebox";
	property name="searchClient" inject="Client@cbelasticsearch";
	property name="jwtService" inject="JWTService@cbsecurity";
	property name="userService" inject="UserService@stachebox";

	/**
	 * Retreives all configured settings
	 **/
	function getAllSettings(){

		var searchBuilder = variables.searchClient.newSearchBuilder().new( moduleSettings.settingsIndex )
									.setQuery( { "match_all" : {} } );
		searchBuilder.setMaxRows( searchBuilder.count() );

		return searchBuilder.execute().getHits().map( function( entry ){
			return expandDoc( entry ).getMemento();
		} );

	}

	/**
	 * Retreives a setting by name
	 *
	 * @name
	 */
	function getByName( required string name ){
		return variables.searchClient.newSearchBuilder()
				.new( moduleSettings.settingsIndex )
				.setQuery( { "term" : { "name.keyword" : arguments.name } } )
				.execute().getHits().reduce(
					( acc, item ) => {
						if( isNull( acc ) ){
							acc = expandDoc( item );
						}
						return acc;
					}
					,javacast( "null", 0 )
				);
	}

	function getById( required string id ){
		var setting = variables.searchClient.get( arguments.id, moduleSettings.settingsIndex );
		if( isNull( setting ) ){
			return;
		} else {
			return expandDoc( setting );
		}
	}

	function expandDoc( required Document doc ){
		var entryMemento = arguments.doc.getMemento();
		entryMemento[ "id" ] = arguments.doc.getId();
		if( isJSON( entryMemento.value ) ){
			entryMemento.value = deserializeJSON( entryMemento.value )
		}
		return arguments.doc;
	}

	/**
	 * Generates a new API token
	 */
	string function generateAPIToken( user, expiration ){
		var timestamp = now();
		param arguments.user = variables.userService.retrieveUserByUsername( variables.moduleSettings.tokenReporter );
		var sub = !isNull( arguments.user ) ? arguments.user.getId() : createUUID();
		arguments.permissions = arguments.user.getPermissions();
		var timestamp = now();
		var params = {
			// Issuing authority
			"iss" : jwtService.getSettings().jwt.issuer,
			"iat" : javacast( "long", jwtService.toEpoch( timestamp ) ),
			"jti"   : hash( timestamp & sub & getTickCount() & rand( "SHA1PRNG" ) ),
			"sub" : sub,
			"scope" : user.getJwtScopes().toList( " " ),
			"exp" : javacast( "long", !isNull( arguments.expiration ) ? jwtService.toEpoch( arguments.expiration ) : jwtService.toEpoch( dateAdd( "yyyy", 10, now() ) ) )
		};

		structAppend( params, arguments.user.getJwtCustomClaims() );

		var jwtToken = jwtService.encode( params );

		if( jwtService.getSettings().jwt.tokenStorage.enabled ) {
			jwtService.getTokenStorage().set(
				key        = params.jti,
				token      = jwtToken,
				expiration = dateDiff(
					"n",
					jwtService.fromEpoch( params.iat ),
					jwtService.fromEpoch( params.exp )
				),
				payload = params
			);
		}

		return jwtToken;
	}

}