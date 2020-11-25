/**
* My BDD Test
*/
component extends="tests.resources.BaseAPITestHelper"{

/*********************************** LIFE CYCLE Methods ***********************************/

	// executes before all suites+specs in the run() method
	function beforeAll(){
		this.loadColdbox = true;
		this.unloadColdbox = false;

		super.beforeAll();

		variables.userModel = getWirebox().getInstance( "UserService@stachebox" );
		variables.userMemento = {
			"firstName" : "Joe",
			"lastName" : "Blow",
			"email" : "Joe@blow.com",
			"password" : "Testing1234$",
			"isAdministrator" : true
		};
		variables.testUser = variables.userModel.getUser()
											.new( userMemento )
											.encryptPassword()
											.save();
		sleep( 1000 );
	}

	// executes after all suites+specs in the run() method
	function afterAll(){
		getWirebox().getInstance( "SearchBuilder@cbElasticsearch" )
					.new( getWirebox().getInstance( "User@stachebox" ).getSearchIndexName() )
					.filterTerm( "email", "Joe@blow.com" )
					.execute()
					.getHits()
					.each( function( doc ){
						doc.delete()
					} );
	}

/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		// all your suites go here.
		describe( "Authentication event specs", function(){

			it( "Tests the login method", function(){
				expect( variables ).toHaveKey( "userMemento" );

				var testEvent = newEventArgs( "POST" );
				testEvent.rc.email = variables.userMemento.email;
				testEvent.rc.password = variables.userMemento.password;

				var event = execute(
					route="/stachebox/api/v1/authentication",
					eventArgs=testEvent,
					renderResults=false
				);

				var prc = event.getCollection( private=true );
				expect( prc ).toHaveKey( "response" );
				expect( prc.response.getStatusCode() ).toBe( 201 );

				var userHeaderIndex = prc.response.getHeaders().find( function( item ){ return item.name == "x-auth-user" } );
				expect( userHeaderIndex ).toBeNumeric().toBeGT( 0 );
				expect( prc.response.getHeaders()[ userHeaderIndex ].value ).toBe( variables.testUser.getId() );


				var tokenHeaderIndex = prc.response.getHeaders().find( function( item ){ return item.name == "x-auth-token" } );
				expect( tokenHeaderIndex ).toBeNumeric().toBeGT( 0 );
				expect( len( prc.response.getHeaders()[ tokenHeaderIndex ].value ) ).toBeGT( 0 );

			});

			it( "Tests the head method", function(){
				expect( variables ).toHaveKey( "userMemento" );
				var auth = getWirebox().getInstance( "AuthenticationService@cbauth" );

				if( !auth.check() ){
					auth.authenticate( variables.userMemento.email, variables.userMemento.password );
				}

				expect( auth.check() ).toBeTrue();


				var testEvent = newEventArgs( "HEAD" );

				var event = execute(
					route="/stachebox/api/v1/authentication",
					eventArgs=testEvent,
					renderResults=false
				);

				var prc = event.getCollection( private=true );
				expect( prc ).toHaveKey( "response" );
				expect( prc.response.getStatusCode() ).toBe( 200 );

				var userHeaderIndex = prc.response.getHeaders().find( function( item ){ return item.name == "x-auth-user" } );
				expect( userHeaderIndex ).toBeNumeric().toBeGT( 0 );
				expect( prc.response.getHeaders()[ userHeaderIndex ].value ).toBe( variables.testUser.getId() );


				var tokenHeaderIndex = prc.response.getHeaders().find( function( item ){ return item.name == "x-auth-token" } );
				expect( tokenHeaderIndex ).toBeNumeric().toBeGT( 0 );
				expect( len( prc.response.getHeaders()[ tokenHeaderIndex ].value ) ).toBeGT( 0 );

			});

			it( "Tests the logout method", function(){
				expect( variables ).toHaveKey( "userMemento" );
				var auth = getWirebox().getInstance( "AuthenticationService@cbauth" );

				if( !auth.check() ){
					auth.authenticate( variables.userMemento.email, variables.userMemento.password );
				}

				expect( auth.check() ).toBeTrue();


				var testEvent = newEventArgs( "DELETE" );

				var event = execute(
					route="/stachebox/api/v1/authentication",
					eventArgs=testEvent,
					renderResults=false
				);

				expect( auth.check() ).toBeFalse();
			});

		});
	}

}

