component singleton {

	property name="moduleSettings" inject="coldbox:moduleSettings:stachebox";
	property name="searchClient" inject="Client@cbelasticsearch";
	property name="jwtService" inject="JWTService@cbsecurity";

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
	string function generateAPIToken( user, array permissions = [ "StacheboxReporter" ], expiration ){
		var timestamp = now();
		var sub = !isNull( arguments.user ) ? arguments.user.getId() : createUUID();
		if( !isNull( arguments.user ) ){
			arguments.permissions = arguments.user.getPermissions();
		}
		var params = {
			// Issuing authority
			"iss" : jwtService.getSettings().jwt.issuer,
			"iat" : dateDiff( 's', dateConvert( "utc2Local", "January 1 1970 00:00" ), now() ),
			"jti"   : hash( timestamp & sub & getTickCount() & rand( "SHA1PRNG" ) ),
			"sub" : sub,
			"scope" : permissions.toList( " " ),
			"exp" : arguments.expiration ?: javacast( "null", 0 )
		};

		if( !isNull( arguments.user ) ){
			structAppend( params, arguments.user.getJwtCustomClaims() );
		}

		return jwtService.encode( params );
	}

}