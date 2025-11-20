component extends="BaseAPIHandler" secured="StacheboxUser"{

	// ( GET ) /api/v1/users
	function index( event, rc, prc ){

		prc.response.setData(
			getInstance( "UserService@stachebox" ).search( rc )
		);

	}

	// ( GET ) /api/v1/users/:id
	function show( event, rc, prc ){

		prc.response.setData(
			getInstance( "User@stachebox" ).getOrFail( rc.id ).getMemento()
		);

	}

	// ( GET ) /api/v1/users/:id/avatar - Returns user avatar
	function avatar( event, rc, prc ){

		var user = getInstance( "User@stachebox" ).getOrFail( rc.id );
		var userMemento = user.getMemento( includes = "avatar" );

		prc.response.setData({
			"id": user.getId(),
			"avatar": userMemento.avatar ?: javacast( "null", 0 )
		});

	}

	// ( POST ) /api/v1/users
	function create( event, rc, prc ) secured="StacheboxAdministrator"{
		var user = getInstance( "User@stachebox" )
									.new( rc )
									.encryptPassword()
									.validateOrFail();

		// Process and validate avatar if provided
		if( !isNull( user.getAvatar() ) && len( user.getAvatar() ) ){
			user.processAvatar();
		}

		prc.response.setData(
				user
				.save()
				.getMemento()
		);
	}

	// ( PUT||PATCH ) /api/v1/users/:id
	function update( event, rc, prc ){
		var user = getInstance( "User@stachebox" ).getOrFail( rc.id );
		user.populate( rc );

		if( event.valueExists( "password" ) && len( rc.password ) ){
			user.encryptPassword();
		}

		// Process and validate avatar if provided
		// Check if user has avatar after population (not just if it's in request)
		if( !isNull( user.getAvatar() ) && len( user.getAvatar() ) ){
			user.processAvatar();
		}

		prc.response.setData( user.save().getMemento() );
	}

	// ( DELETE ) /api/v1/users/:id
	function delete( event, rc, prc ) secured="StacheboxAdministrator"{
		getInstance( "User@stachebox" )
				.getOrFail( rc.id )
				.delete();
		prc.response.setStatusCode( STATUS.NO_CONTENT );
	}

}