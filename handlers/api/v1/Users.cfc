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

	// ( POST ) /api/v1/users
	function create( event, rc, prc ) secured="StacheboxAdministrator"{
		var user = getInstance( "User@stachebox" )
									.new( rc )
									.encryptPassword()
									.validateOrFail();
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