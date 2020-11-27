component extends="BaseAPIHandler" secured{

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
	function create( event, rc, prc ) secured="Stachebox:Administrator"{
		prc.response.setData(
			getInstance( "User@stachebox" )
				.new( rc )
				.validateOrFail()
				.save()
				.getMemento()
		);
	}

	// ( PUT||PATCH ) /api/v1/users/:id
	function update( event, rc, prc ){
		var user = getInstance( "User@stachebox" ).getOrFail( rc.id );
		user.populate( rc ).save();
		prc.response.setData( user.getMemento() );
	}

	// ( DELETE ) /api/v1/users/:id
	function delete( event, rc, prc ){
		getInstance( "User@stachebox" )
				.getOrFail( rc.id )
				.delete();
		prc.response.setStatusCode( STATUS.NO_CONTENT );
	}

}